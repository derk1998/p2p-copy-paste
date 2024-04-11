import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/ice_server_configuration.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/use_cases/close_connection.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';

abstract class IJoinConnectionService
    implements CloseConnectionUseCase, TransceiveDataUseCase {
  Future<void> joinConnection(String connectionId);
  void setOnConnectedListener(void Function() onConnectedListener);
}

class JoinConnectionService extends AbstractConnectionService
    implements IJoinConnectionService {
  JoinConnectionService({required this.connectionInfoRepository});

  ConnectionInfo? _connectionInfo;
  RTCPeerConnection? _peerConnection;
  StreamSubscription<ConnectionInfo?>? _subscription;
  final IConnectionInfoRepository connectionInfoRepository;

  @override
  Future<void> joinConnection(String connectionId) async {
    if (_subscription != null) {
      await _subscription!.cancel();
    }

    //signaling
    _connectionInfo = await connectionInfoRepository.getRoomById(connectionId);

    //local config
    _peerConnection = await createPeerConnection(iceServerConfiguration);

    _peerConnection!.onDataChannel = (channel) {
      setDataChannel(channel);

      channel.onDataChannelState = (state) {
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          //Workaround for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
          callOnDisconnectedListener();
        }

        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          callOnConnectedListener();
        }
      };

      //When the peer is disconnected due to closing the app
      _peerConnection!.onIceConnectionState = (state) {
        if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          callOnDisconnectedListener();
        }
      };

      //Works on android
      //not for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
      _peerConnection!.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          callOnDisconnectedListener();
        }
      };
    };

    _peerConnection!.onIceCandidate = (candidate) {
      _connectionInfo!.addIceCandidateB(candidate);
      connectionInfoRepository.updateRoom(_connectionInfo!);
    };

    _peerConnection!.setRemoteDescription(_connectionInfo!.offer!);

    _subscription = connectionInfoRepository
        .roomSnapshots(_connectionInfo!.id!)
        .listen((snapshot) {
      if (_connectionInfo!.iceCandidatesA.isNotEmpty) {
        for (final iceCandidate in _connectionInfo!.iceCandidatesA) {
          _peerConnection!.addCandidate(iceCandidate);
        }
      }
    });

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    //signaling
    _connectionInfo = await connectionInfoRepository.updateRoom(
        ConnectionInfo.join(id: _connectionInfo!.id!, answer: answer));
  }

  //todo: move to base
  @override
  void close() async {
    if (_peerConnection != null) {
      await _peerConnection!.close();
    }
  }

  @override
  void setOnConnectionClosedListener(
      void Function() onConnectionClosedListener) {
    setOnDisconnectedListener(onConnectionClosedListener);
  }

  @override
  void setOnConnectedListener(void Function() onConnectedListener) {
    setOnConnectedListenerImpl(onConnectedListener);
  }

  @override
  void sendData(String data) {
    sendDataImpl(data);
  }

  @override
  void setOnReceiveDataListener(
      void Function(String data) onReceiveDataListener) {
    setOnReceiveDataListener(onReceiveDataListener);
  }
}
