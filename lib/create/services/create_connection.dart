import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/ice_server_configuration.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';

abstract class ICreateConnectionService implements TransceiveDataUseCase {
  Future<void> createConnection(String ownUid, String visitor);

  void setOnConnectedListener(void Function() onConnectedListener);
  Future<void> setVisitor(String ownUid, String visitor);
}

class CreateConnectionService extends AbstractConnectionService
    implements ICreateConnectionService {
  CreateConnectionService({required this.connectionInfoRepository});

  final IConnectionInfoRepository connectionInfoRepository;
  ConnectionInfo? ownConnectionInfo;
  RTCPeerConnection? peerConnection;
  StreamSubscription<ConnectionInfo?>? _subscription;

  //todo: this is a mess
  bool answerSet = false;
  bool answerSetting = false;

  Future<void> _openDataChannel() async {
    setDataChannel(await peerConnection!
        .createDataChannel('clipboard', RTCDataChannelInit()..id = 1));

    dataChannel?.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelClosed) {
        //Workaround for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
        callOnDisconnectedListener();
      }

      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        callOnConnectedListener();
      }
    };
  }

  Future<RTCSessionDescription> _configureLocal(String ownUid) async {
    peerConnection = await createPeerConnection(iceServerConfiguration);
    ownConnectionInfo = await connectionInfoRepository.getRoomById(ownUid);

    assert(ownConnectionInfo!.visitor != null);

    //Works on android
    //not for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
    peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        callOnDisconnectedListener();
      }
    };

    //When the peer is disconnected due to closing the app
    peerConnection!.onIceConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        callOnDisconnectedListener();
      }
    };

    await _openDataChannel();

    final offer = await peerConnection!.createOffer();

    peerConnection!.onIceCandidate = (candidate) async {
      ownConnectionInfo!.addIceCandidate(candidate);
      await connectionInfoRepository.updateRoom(ownConnectionInfo!);
      log('Ice candidate sent');
    };

    //Responsible for gathering ice candidates
    await peerConnection!.setLocalDescription(offer);
    return offer;
  }

  void _configureRemote(RTCSessionDescription offer, String visitor) {
    log('Configure remote...');

    ownConnectionInfo!.setOffer(offer);
    connectionInfoRepository.updateRoom(ownConnectionInfo!);
    log('Offer generated and sent');
  }

  @override
  Future<void> setVisitor(String ownUid, String visitor) async {
    await connectionInfoRepository.deleteRoom(ConnectionInfo(id: ownUid));
    await connectionInfoRepository
        .addRoom(ConnectionInfo(id: ownUid)..visitor = visitor);
  }

  void _handleSignalingAnswers(String visitor) {
    log('Handling signaling answers...');

    log('visitor: $visitor');
    _subscription = connectionInfoRepository
        .roomSnapshots(visitor)
        .listen((connectionInfo) async {
      if (connectionInfo == null) {
        return;
      }

      if (connectionInfo.answer != null && !answerSetting && !answerSet) {
        peerConnection!
            .setRemoteDescription(connectionInfo.answer!)
            .then((value) {
          answerSet = true;
        });
        answerSetting = true;
        log('Answer is set');
      }

      if (connectionInfo.iceCandidates.isNotEmpty && answerSet) {
        for (final iceCandidate in connectionInfo.iceCandidates) {
          log('Add ice candidate (create)');
          try {
            await peerConnection!.addCandidate(iceCandidate);
          } catch (e) {
            log('Could not add ice candidate');
          }
        }
      }
    });
  }

  @override
  Future<void> createConnection(String ownUid, String visitor) async {
    log('Creating connection...');
    _handleSignalingAnswers(visitor);

    final offer = await _configureLocal(ownUid);
    _configureRemote(offer, visitor);
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
    if (peerConnection != null) {
      peerConnection!.close();
    }
  }

  @override
  void dispose() {
    log('Create connection dispose');
    _subscription?.cancel();
    close();
  }
}
