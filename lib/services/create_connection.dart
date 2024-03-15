import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:test_webrtc/services/connection.dart';
import 'package:test_webrtc/ice_server_configuration.dart';
import 'package:test_webrtc/connection_info.dart';
import 'package:test_webrtc/connection_info_repository.dart';
import 'package:test_webrtc/use_cases/close_connection.dart';

class CreateConnectionService extends AbstractConnectionService
    implements CloseConnectionUseCase {
  CreateConnectionService(this.ref);

  final Ref ref;
  void Function(String id)? _onConnectionIdPublished;
  ConnectionInfo? connectionInfo;
  RTCPeerConnection? peerConnection;
  StreamSubscription<ConnectionInfo?>? _subscription;
  bool answerSet = false;
  void Function()? _onConnectionClosedListener;
  Completer<void>? _roomCreation;

  Future<void> _openDataChannel() async {
    setDataChannel(await peerConnection!
        .createDataChannel('clipboard', RTCDataChannelInit()..id = 1));

    dataChannel?.onDataChannelState = (state) {
      log('DATA CHANNEL STATE: $state');
      if (state == RTCDataChannelState.RTCDataChannelClosed) {
        //Workaround for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
        if (_onConnectionClosedListener != null) {
          _onConnectionClosedListener!.call();
        }
      }

      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        callOnConnectedListener();
      }
    };
  }

  Future<RTCSessionDescription> _configureLocal() async {
    peerConnection = await createPeerConnection(iceServerConfiguration);
    connectionInfo ??= ConnectionInfo();

    //Works on android
    //not for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
    peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed &&
          _onConnectionClosedListener != null) {
        _onConnectionClosedListener!.call();
      }
    };

    await _openDataChannel();

    final offer = await peerConnection!.createOffer();

    peerConnection!.onIceCandidate = (candidate) async {
      log(candidate.candidate!);
      await _roomCreation!.future;
      connectionInfo!.addIceCandidateA(candidate);
      ref.read(connectionInfoRepositoryProvider).updateRoom(connectionInfo!);
    };

    //Responsible for gathering ice candidates
    await peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<void> _configureRemote(RTCSessionDescription offer) async {
    connectionInfo!.setOffer(offer);
    connectionInfo = await ref
        .read(connectionInfoRepositoryProvider)
        .addRoom(connectionInfo!);
    _roomCreation!.complete();
    log('ROOM ID: ${connectionInfo?.id}');

    _handleSignalingAnswers();

    if (_onConnectionIdPublished != null) {
      _onConnectionIdPublished!.call(connectionInfo!.id!);
    }
  }

  void _handleSignalingAnswers() {
    _subscription = ref
        .watch(connectionInfoRepositoryProvider)
        .roomSnapshots(connectionInfo!.id!)
        .listen((connectionInfo) {
      if (connectionInfo!.answer != null &&
          peerConnection!.signalingState !=
              RTCSignalingState.RTCSignalingStateStable &&
          !answerSet) {
        log('Received answer!');
        peerConnection!.setRemoteDescription(connectionInfo.answer!);
        answerSet = true;
      }

      if (connectionInfo.iceCandidatesB.isNotEmpty && answerSet) {
        for (final iceCandidate in connectionInfo.iceCandidatesB) {
          log('Adding ice candidate: ${iceCandidate.candidate}');
          peerConnection!.addCandidate(iceCandidate);
        }
      }
    });
  }

  Future<void> startNewConnection() async {
    if (_subscription != null) {
      await _subscription!.cancel();
    }
    _roomCreation = Completer<void>();
    answerSet = false;

    final offer = await _configureLocal();
    await _configureRemote(offer);
  }

  void setOnConnectionIdPublished(
      void Function(String id) onConnectionIdPublished) {
    _onConnectionIdPublished = onConnectionIdPublished;
  }

  //todo: move to base
  @override
  void close() async {
    if (peerConnection != null) {
      log('CONNECTION CLOSED');
      await peerConnection!.close();
    }
  }

  @override
  void setOnConnectionClosedListener(
      void Function() onConnectionClosedListener) {
    _onConnectionClosedListener = onConnectionClosedListener;
  }
}

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
CreateConnectionService? _connectionService;

final createConnectionServiceProvider =
    Provider<CreateConnectionService>((ref) {
  _connectionService ??= CreateConnectionService(ref);
  return _connectionService!;
});
