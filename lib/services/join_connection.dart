import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:test_webrtc/services/connection.dart';
import 'package:test_webrtc/ice_server_configuration.dart';
import 'package:test_webrtc/connection_info.dart';
import 'package:test_webrtc/connection_info_repository.dart';
import 'package:test_webrtc/use_cases/close_connection.dart';

class JoinConnectionService extends AbstractConnectionService
    implements CloseConnectionUseCase {
  JoinConnectionService(this.ref);

  final Ref ref;
  ConnectionInfo? _connectionInfo;
  RTCPeerConnection? _peerConnection;
  final List<RTCIceCandidate> _gatheredIceCandidates = [];
  void Function()? _onConnectionClosedListener;

  Future<void> joinConnection(String connectionId) async {
    //signaling
    _connectionInfo = await ref
        .read(connectionInfoRepositoryProvider)
        .getRoomById(connectionId);

    //local config
    _peerConnection = await createPeerConnection(iceServerConfiguration);

    _peerConnection!.onDataChannel = (channel) {
      setDataChannel(channel);

      channel.onDataChannelState = (state) {
        log('DATA CHANNEL STATE CHANGED! -> $state');
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

      //Works on android
      //not for web: https://github.com/flutter-webrtc/flutter-webrtc/issues/1548
      _peerConnection!.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed &&
            _onConnectionClosedListener != null) {
          _onConnectionClosedListener!.call();
        }
      };
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
    _onConnectionClosedListener = onConnectionClosedListener;
  }
}

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
JoinConnectionService? _connectionService;

final joinConnectionServiceProvider = Provider<JoinConnectionService>((ref) {
  _connectionService ??= JoinConnectionService(ref);
  return _connectionService!;
});
