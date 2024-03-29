import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/view_models/home.dart';
import 'package:test_webrtc/widgets/button.dart' as btn;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel =
        ref.read(homeScreenViewModelProvider(Navigator.of(context)));

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              btn.Button(
                  viewModel: viewModel.startNewConnectionButtonViewModel),
              const SizedBox(
                height: 16,
              ),
              if (viewModel.joinConnectionButtonViewModel != null)
                btn.Button(viewModel: viewModel.joinConnectionButtonViewModel!),
              if (viewModel.joinWithQrCodeButtonViewModel != null) ...[
                const SizedBox(
                  height: 16,
                ),
                btn.IconButton(
                    viewModel: viewModel.joinWithQrCodeButtonViewModel!)
              ],
            ],
          ),
        ),
      ),
    );
  }
}
