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

    pc.onDataChannel = (channel) {
      setDataChannel(channel);
    };
  }

  @override
  Future<void> onPeerConnectionInfoChanged(ConnectionInfo? peerConnectionInfo,
      RTCPeerConnection peerConnection) async {
    if (peerConnectionInfo == null) return;

    if (peerConnectionInfo.offer != null && !offerSet) {
      peerConnection.setRemoteDescription(peerConnectionInfo.offer!);
      log('Offer set!');
      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);

      ownConnectionInfo!.answer = answer;
      await connectionInfoRepository.target!.updateRoom(ownConnectionInfo!);
      log('Answer generated and sent');
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
