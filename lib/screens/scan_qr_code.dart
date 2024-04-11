import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:p2p_copy_paste/view_models/scan_qr_code.dart';

class ScanQRCodeScreen extends StatefulWidget {
  const ScanQRCodeScreen({super.key, required this.viewModel});

  final ScanQrCodeScreenViewModel viewModel;

  @override
  State<ScanQRCodeScreen> createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  QRViewController? qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    widget.viewModel.init();
    super.initState();
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.viewModel.title),
        ),
        body: QRView(
          key: qrKey,
          onQRViewCreated: (controller) {
            qrViewController = controller;
            qrViewController?.scannedDataStream.listen((scanData) {
              if (scanData.code != null) {
                widget.viewModel.onQrCodeScanned(scanData.code!);
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
        ));
  }
}
