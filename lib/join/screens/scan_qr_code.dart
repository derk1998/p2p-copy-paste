import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:p2p_copy_paste/join/view_models/scan_qr_code.dart';

class ScanQRCodeScreen extends StatefulScreenView<ScanQrCodeScreenViewModel> {
  const ScanQRCodeScreen({super.key, required super.viewModel});

  @override
  State<ScanQRCodeScreen> createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends StatefulScreenViewState<ScanQRCodeScreen,
    ScanQrCodeScreenViewModel> {
  QRViewController? qrViewController;
  StreamSubscription<Barcode>? subscription;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void dispose() {
    subscription?.cancel();
    qrViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) {
        qrViewController = controller;
        subscription = qrViewController?.scannedDataStream.listen((scanData) {
          if (scanData.code != null) {
            viewModel.onQrCodeScanned(scanData.code!);
          }
        });
      },
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 5,
        cutOutSize: 300,
      ),
    );
  }
}
