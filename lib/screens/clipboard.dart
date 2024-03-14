import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/services/connection_service.dart';
import 'package:test_webrtc/view_models/clipboard.dart';

class ClipboardScreen extends ConsumerWidget {
  const ClipboardScreen({super.key, required this.dataTransceiver});

  final DataTransceiver dataTransceiver;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final provider = clipboardViewModelProvider(dataTransceiver);
    final AsyncValue<String> state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.hasValue) Text(state.value!),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  onPressed: viewModel.onCopyButtonPressed,
                  label: const Text('Copy'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.paste),
                  onPressed: viewModel.onPasteButtonPressed,
                  label: const Text('Paste'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
