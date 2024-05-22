import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';
import 'package:p2p_copy_paste/services/connection.dart';

class JoinConnectionService extends AbstractConnectionService {
  JoinConnectionService({required super.connectionInfoRepository});

  bool offerSet = false;

  @override
  Future<void> connect(String ownUid, String visitor) async {
    final pc = await setupPeerConnection(ownUid, visitor);

    pc.onSignalingState = (state) async {
      if (state == RTCSignalingState.RTCSignalingStateHaveRemoteOffer) {
        final answer = await pc.createAnswer();
        await pc.setLocalDescription(answer);

        ownConnectionInfo!.answer = answer;
        await connectionInfoRepository.target!.updateRoom(ownConnectionInfo!);
        log('Answer generated and sent');
      }
    };

    pc.onDataChannel = (channel) {
      setDataChannel(channel);
    };
  }

  @override
  Future<void> onPeerConnectionInfoChanged(ConnectionInfo? peerConnectionInfo,
      RTCPeerConnection peerConnection) async {
    if (peerConnectionInfo == null) return;

    if (peerConnectionInfo.offer != null && !offerSet) {
      log('Offer set!');
      await peerConnection.setRemoteDescription(peerConnectionInfo.offer!);
      offerSet = true;
    }

    if (peerConnectionInfo.iceCandidates.isNotEmpty && offerSet) {
      for (final iceCandidate in peerConnectionInfo.iceCandidates) {
        log('Add ice candidate (joiner)');
        peerConnection.addCandidate(iceCandidate);
      }
    }
  }
}
