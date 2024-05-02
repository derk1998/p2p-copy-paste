import 'dart:convert';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/connect_dialog.dart';
import 'package:p2p_copy_paste/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/view_models/connect_dialog.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:p2p_copy_paste/models/invite.dart';

class ScanQrCodeScreenViewModel extends ScreenViewModel {
  final List<String> _scannedCodes = [];

  ScanQrCodeScreenViewModel(
      {required this.navigator,
      required this.clipboardService,
      required this.joinConnectionService,
      required this.joinInviteService});

  final INavigator navigator;
  final IClipboardService clipboardService;
  final IJoinConnectionService joinConnectionService;
  final IJoinInviteService joinInviteService;

  @override
  void init() {}

  @override
  void dispose() {}

  void _join(Invite invite) {
    navigator.replaceScreen(
      ConnectDialog(
        viewModel: ConnectDialogViewModel(
            clipboardService: clipboardService,
            getJoinNewInvitePageView: () => ScanQRCodeScreen(
                  viewModel: ScanQrCodeScreenViewModel(
                      navigator: navigator,
                      clipboardService: clipboardService,
                      joinConnectionService: joinConnectionService,
                      joinInviteService: joinInviteService),
                ),
            invite: invite,
            navigator: navigator,
            joinConnectionService: joinConnectionService,
            joinInviteService: joinInviteService),
      ),
    );
  }

  void onQrCodeScanned(String code) {
    if (!_scannedCodes.contains(code)) {
      _scannedCodes.add(code);
      try {
        final Map<String, dynamic> inviteData = jsonDecode(code);
        inviteData['timestamp'] = DateTime.parse(inviteData['timestamp']);
        final invite = Invite.fromMap(inviteData);
        _join(invite);
      } catch (e) {
        //ignore, keep trying
      }
    }
  }

  @override
  String title() {
    return 'Scan QR code';
  }
}
