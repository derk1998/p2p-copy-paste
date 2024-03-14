import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:test_webrtc/services/connection_service.dart';
import 'package:test_webrtc/ice_server_configuration.dart';
import 'package:test_webrtc/connection_info.dart';
import 'package:test_webrtc/connection_info_repository.dart';

class JoinConnectionService extends AbstractConnectionService {
  JoinConnectionService(this.ref);

  final Ref ref;
  ConnectionInfo? _connectionInfo;
  RTCPeerConnection? _peerConnection;
  final List<RTCIceCandidate> _gatheredIceCandidates = [];

  Future<void> joinConnection(String connectionId) async {
    //signaling
    _connectionInfo = await ref
        .read(connectionInfoRepositoryProvider)
        .getRoomById(connectionId);

    //local config
    _peerConnection = await createPeerConnection(iceServerConfiguration);

    _peerConnection!.onDataChannel = (channel) {
      setDataChannel(channel);
      callOnConnectedListener();
    };

    _peerConnection!.onIceCandidate = (candidate) {
      log(candidate.candidate!);
      _gatheredIceCandidates.add(candidate);
    };

    _peerConnection!.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateGathering) {
        log('START ICE CANDIDATE GATHERING');
        _gatheredIceCandidates.clear();
      }

      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        log('DONE ICE CANDIDATE GATHERING');

        for (final candidate in _gatheredIceCandidates) {
          _connectionInfo!.addIceCandidateB(candidate);
        }
        ref.read(connectionInfoRepositoryProvider).updateRoom(_connectionInfo!);
      }
    };

    _peerConnection!.setRemoteDescription(_connectionInfo!.offer!);

    for (final candidate in _connectionInfo!.iceCandidatesA) {
      log('Add candidate: ${candidate.candidate}');
      _peerConnection!.addCandidate(candidate);
    }

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    //signaling
    _connectionInfo = await ref
        .read(connectionInfoRepositoryProvider)
        .updateRoom(
            ConnectionInfo.join(id: _connectionInfo!.id!, answer: answer));
  }
}

JoinConnectionService? _connectionService;

final joinConnectionServiceProvider = Provider<JoinConnectionService>((ref) {
  _connectionService ??= JoinConnectionService(ref);
  return _connectionService!;
});
