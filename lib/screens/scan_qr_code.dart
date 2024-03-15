import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:test_webrtc/view_models/scan_qr_code.dart';

class ScanQRCodeScreen extends ConsumerWidget {
  const ScanQRCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider =
        joinWithQrCodeScreenViewModelProvider(Navigator.of(context));
    final AsyncValue<String> state = ref.watch(viewModelProvider);
    final viewModel = ref.read(viewModelProvider.notifier);

    return Scaffold(
      body: Stack(children: [
        QRView(
          key: viewModel.qrKey,
          onQRViewCreated: viewModel.onCreated,
        ),
        if (state.isLoading)
          Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.value!),
                  const SizedBox(
                    height: 16,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          )
      ]),
    );
  }
}
