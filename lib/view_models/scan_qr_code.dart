import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/view_models/abstract_join_connection.dart';

class ScanQrCodeScreenViewModel extends AbstractJoinConnectionScreenViewModel {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final List<String> _scannedCodes = [];

  void onCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && !_scannedCodes.contains(scanData.code)) {
        _scannedCodes.add(scanData.code!);
        try {
          final Map<String, dynamic> inviteData = jsonDecode(scanData.code!);
          inviteData['timestamp'] = DateTime.parse(inviteData['timestamp']);
          final invite = Invite.fromMap(inviteData);
          join(invite);
        } catch (e) {
          //ignore, keep trying
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
  }
}

final joinWithQrCodeScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<ScanQrCodeScreenViewModel, String,
        NavigatorState>(() {
  return ScanQrCodeScreenViewModel();
});
