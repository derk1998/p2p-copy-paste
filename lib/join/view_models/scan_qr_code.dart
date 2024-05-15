import 'dart:async';
import 'dart:convert';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/models/invite.dart';

class ScanQrCodeScreenViewModel extends StatefulScreenViewModel {
  final List<String> _scannedCodes = [];

  ScanQrCodeScreenViewModel(
      {required this.joinInviteService,
      required this.inviteRetrievedCondition});

  final IJoinInviteService joinInviteService;
  final StreamController<Invite> inviteRetrievedCondition;

  void onQrCodeScanned(String code) {
    if (!_scannedCodes.contains(code)) {
      _scannedCodes.add(code);
      try {
        final Map<String, dynamic> inviteData = jsonDecode(code);
        inviteData['timestamp'] = DateTime.parse(inviteData['timestamp']);
        final invite = Invite.fromMap(inviteData);

        inviteRetrievedCondition.add(invite);
      } catch (e) {
        //ignore, keep trying
      }
    }
  }

  @override
  String getTitle() {
    return 'Scan QR code';
  }

  @override
  void dispose() {}

  @override
  void init() {}
}
