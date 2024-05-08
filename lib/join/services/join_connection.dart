import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/ice_server_configuration.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';

abstract class IJoinConnectionService implements TransceiveDataUseCase {
  Future<void> joinConnection(String ownUid, String visitor);
  void setOnConnectedListener(void Function() onConnectedListener);
  Future<void> addVisitor(String ownUid, String visitor);
}

class JoinConnectionService extends AbstractConnectionService
    implements IJoinConnectionService {
  JoinConnectionService({required this.connectionInfoRepository});

  ConnectionInfo? _ownConnectionInfo;
  RTCPeerConnection? _peerConnection;
  StreamSubscription<ConnectionInfo?>? _subscription;
  final IConnectionInfoRepository connectionInfoRepository;
  bool offerSet = false;

  @override
  Future<void> addVisitor(String ownUid, String visitor) async {
    await connectionInfoRepository.deleteRoom(ConnectionInfo(id: ownUid));
    await connectionInfoRepository
        .addRoom(ConnectionInfo(id: ownUid)..visitor = visitor);
  }

  @override
  Future<void> joinConnection(String ownUid, String visitor) async {
    //signaling
    _ownConnectionInfo = await connectionInfoRepository.getRoomById(ownUid);

    assert(_ownConnectionInfo!.visitor != null);

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
      _ownConnectionInfo!.addIceCandidate(candidate);
      connectionInfoRepository.updateRoom(_ownConnectionInfo!);
      log('Sent ice candidate');
    };

    _subscription = connectionInfoRepository
        .roomSnapshots(visitor)
        .listen((snapshot) async {
      if (snapshot == null) return;

      if (snapshot.offer != null && !offerSet) {
        _peerConnection!.setRemoteDescription(snapshot.offer!);
        log('Offer set!');
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        //signaling
        _ownConnectionInfo!.answer = answer;
        await connectionInfoRepository.updateRoom(_ownConnectionInfo!);
        log('Answer generated and sent');

        offerSet = true;
      }

      if (snapshot.iceCandidates.isNotEmpty && offerSet) {
        for (final iceCandidate in snapshot.iceCandidates) {
          log('Add ice candidate (joiner)');
          _peerConnection!.addCandidate(iceCandidate);
        }
      }
    });
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
    setOnReceiveDataListenerImpl(onReceiveDataListener);
  }

  @override
  void close() {
    if (_peerConnection != null) {
      _peerConnection!.close();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    close();
  }
}
