import 'package:flutter/material.dart';
import 'package:test_webrtc/view_models/code_expired.dart';
import 'package:test_webrtc/widgets/pure_icon_button.dart';

class CodeExpiredScreen extends StatelessWidget {
  const CodeExpiredScreen({super.key, required this.viewModel});

  final CodeExpiredViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Your QR code has expired. Do you want to create a new one?'),
            PureIconButton(viewModel: viewModel.iconButtonViewModel)
          ],
        ),
      ),
    );
  }
}
