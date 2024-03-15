import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:test_webrtc/view_models/abstract_join_connection.dart';

class ScanQrCodeScreenViewModel extends AbstractJoinConnectionScreenViewModel {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final List<String> _scannedCodes = [];

  void onCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && !_scannedCodes.contains(scanData.code)) {
        _scannedCodes.add(scanData.code!);
        join(scanData.code!);
        Future.delayed(const Duration(seconds: 10), () {
          if (state.isLoading) {
            state = const AsyncValue.data('Failed to connect');
          }
        });
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
