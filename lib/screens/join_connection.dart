import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/view_models/join_connection.dart';
import 'package:test_webrtc/widgets/button.dart';

class JoinConnectionScreen extends ConsumerWidget {
  const JoinConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider =
        joinConnectionScreenViewModelProvider(Navigator.of(context));
    final AsyncValue<String> state = ref.watch(viewModelProvider);
    final viewModel = ref.read(viewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: viewModel.codeController,
              ),
              const SizedBox(
                height: 16,
              ),
              Button(viewModel: viewModel.connectButtonViewModel),
              const SizedBox(
                height: 16,
              ),
              state.isLoading
                  ? const CircularProgressIndicator()
                  : Text(state.value == null ? 'no data' : state.value!)
            ],
          ),
        ),
      ),
    );
  }
}
