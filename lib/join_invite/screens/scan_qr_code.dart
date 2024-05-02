import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:p2p_copy_paste/join_invite/view_models/scan_qr_code.dart';

class ScanQRCodeScreen extends ScreenView<ScanQrCodeScreenViewModel> {
  const ScanQRCodeScreen({super.key, required super.viewModel});

  @override
  State<ScanQRCodeScreen> createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState
    extends ScreenViewState<ScanQRCodeScreen, ScanQrCodeScreenViewModel> {
  QRViewController? qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) {
        qrViewController = controller;
        qrViewController?.scannedDataStream.listen((scanData) {
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
