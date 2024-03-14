import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:test_webrtc/services/connection_service.dart';
import 'package:test_webrtc/ice_server_configuration.dart';
import 'package:test_webrtc/connection_info.dart';
import 'package:test_webrtc/connection_info_repository.dart';

class CreateConnectionService extends AbstractConnectionService {
  CreateConnectionService(this.ref);

  final Ref ref;
  void Function(String id)? _onConnectionIdPublished;
  ConnectionInfo? connectionInfo;
  RTCPeerConnection? peerConnection;
  StreamSubscription<ConnectionInfo?>? _subscription;
  bool answerSet = false;
  final List<RTCIceCandidate> _gatheredIceCandidates = [];

  Future<void> _openDataChannel() async {
    setDataChannel(await peerConnection!
        .createDataChannel('clipboard', RTCDataChannelInit()..id = 1));

    dataChannel?.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        callOnConnectedListener();
      }
    };
  }

  Future<RTCSessionDescription> _configureLocal() async {
    final c = Completer<RTCSessionDescription>();
    peerConnection = await createPeerConnection(iceServerConfiguration);
    connectionInfo ??= ConnectionInfo();

    await _openDataChannel();

    final offer = await peerConnection!.createOffer();

    peerConnection!.onIceCandidate = (candidate) {
      log(candidate.candidate!);
      _gatheredIceCandidates.add(candidate);
    };

    peerConnection!.onIceGatheringState = (state) async {
      if (state == RTCIceGatheringState.RTCIceGatheringStateGathering) {
        log('START GATHERING ICE CANDIDATES');
        _gatheredIceCandidates.clear();
      }

      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        log('DONE GATHERING ICE CANDIDATES');

        for (final candidate in _gatheredIceCandidates) {
          connectionInfo!.addIceCandidateA(candidate);
        }
        c.complete(offer);
      }
    };

    //Responsible for gathering ice candidates
    await peerConnection!.setLocalDescription(offer);

    return c.future;
  }

  Future<void> _configureRemote(RTCSessionDescription offer) async {
    connectionInfo!.setOffer(offer);
    connectionInfo = await ref
        .read(connectionInfoRepositoryProvider)
        .addRoom(connectionInfo!);
    log('ROOM ID: ${connectionInfo?.id}');

    _handleSignalingAnswers();

    if (_onConnectionIdPublished != null) {
      _onConnectionIdPublished!.call(connectionInfo!.id!);
    }
  }

  //todo: do this for the joining side as well
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
    answerSet = false;

    final offer = await _configureLocal();
    await _configureRemote(offer);
  }

  void setOnConnectionIdPublished(
      void Function(String id) onConnectionIdPublished) {
    _onConnectionIdPublished = onConnectionIdPublished;
  }
}

CreateConnectionService? _connectionService;

final createConnectionServiceProvider =
    Provider<CreateConnectionService>((ref) {
  _connectionService ??= CreateConnectionService(ref);
  return _connectionService!;
});
