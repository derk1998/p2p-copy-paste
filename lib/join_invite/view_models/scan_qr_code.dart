import 'dart:async';
import 'dart:convert';

import 'package:p2p_copy_paste/join_invite/join_invite_service.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:p2p_copy_paste/models/invite.dart';

class ScanQrCodeScreenViewModel extends ScreenViewModel {
  final List<String> _scannedCodes = [];

  ScanQrCodeScreenViewModel(
      {required this.joinInviteService,
      required this.inviteRetrievedCondition});

  final IJoinInviteService joinInviteService;
  final StreamController<Invite> inviteRetrievedCondition;

  @override
  void init() {}

  @override
  void dispose() {}

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
}
