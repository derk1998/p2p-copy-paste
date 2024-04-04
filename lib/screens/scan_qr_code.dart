import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:p2p_copy_paste/view_models/scan_qr_code.dart';

class ScanQRCodeScreen extends ConsumerWidget {
  const ScanQRCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider =
        joinWithQrCodeScreenViewModelProvider(Navigator.of(context));
    final viewModel = ref.watch(viewModelProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          title: Text(viewModel.title),
        ),
        body: QRView(
          key: viewModel.qrKey,
          onQRViewCreated: viewModel.onCreated,
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
