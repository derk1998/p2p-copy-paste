import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_copy_paste/models/connection_info.dart';
import 'package:p2p_copy_paste/services/connection.dart';

class CreateConnectionService extends AbstractConnectionService {
  CreateConnectionService({required super.connectionInfoRepository});

  bool answerSet = false;

  @override
  Future<void> connect(String ownUid, String visitor) async {
    final pc = await setupPeerConnection(ownUid, visitor);

    pc.onRenegotiationNeeded = () async {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      ownConnectionInfo!.setOffer(offer);
      connectionInfoRepository.target!.updateRoom(ownConnectionInfo!);
    };

    setDataChannel(
        await pc.createDataChannel('clipboard', RTCDataChannelInit()..id = 1));
  }

  @override
  Future<void> onPeerConnectionInfoChanged(ConnectionInfo? peerConnectionInfo,
      RTCPeerConnection peerConnection) async {
    if (peerConnectionInfo == null) {
      return;
    }

    if (peerConnectionInfo.answer != null && !answerSet) {
      await peerConnection.setRemoteDescription(peerConnectionInfo.answer!);
      answerSet = true;
      log('Answer is set');
    } else if (peerConnectionInfo.iceCandidates.isNotEmpty) {
      for (final iceCandidate in peerConnectionInfo.iceCandidates) {
        log('Add ice candidate (create)');
        try {
          await peerConnection.addCandidate(iceCandidate);
        } catch (e) {
          log('Could not add ice candidate');
        }
      }
    }
  }
}
