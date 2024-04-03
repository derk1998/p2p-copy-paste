import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/screens/connect_dialog.dart';
import 'package:p2p_copy_paste/screens/scan_qr_code.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:p2p_copy_paste/models/invite.dart';

class ScanQrCodeScreenViewModel
    extends AutoDisposeFamilyAsyncNotifier<void, NavigatorState> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final List<String> _scannedCodes = [];
  late NavigatorState _navigator;
  final String title = 'Scan QR code';

  @override
  FutureOr<void> build(NavigatorState arg) {
    _navigator = arg;
    ref.onDispose(_dispose);
  }

  void _dispose() {
    controller?.dispose();
  }

  void _join(Invite invite) {
    _navigator.pushReplacement(MaterialPageRoute(
      builder: (context) => ConnectDialog(
        invite: invite,
        navigator: _navigator,
        getJoinNewInvitePageRoute: () => MaterialPageRoute(
          builder: (context) => const ScanQRCodeScreen(),
        ),
      ),
    ));
  }

  void onCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && !_scannedCodes.contains(scanData.code)) {
        _scannedCodes.add(scanData.code!);
        try {
          final Map<String, dynamic> inviteData = jsonDecode(scanData.code!);
          inviteData['timestamp'] = DateTime.parse(inviteData['timestamp']);
          final invite = Invite.fromMap(inviteData);
          _join(invite);
        } catch (e) {
          //ignore, keep trying
        }
      }
    });
  }
}

final joinWithQrCodeScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<ScanQrCodeScreenViewModel, void,
        NavigatorState>(() {
  return ScanQrCodeScreenViewModel();
});
