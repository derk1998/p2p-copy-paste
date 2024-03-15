import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/services/connection.dart';
import 'package:test_webrtc/use_cases/close_connection.dart';
import 'package:test_webrtc/view_models/clipboard.dart';
import 'package:test_webrtc/widgets/button.dart' as btn;

class ClipboardScreen extends ConsumerWidget {
  ClipboardScreen(
      {super.key,
      required DataTransceiver dataTransceiver,
      required CloseConnectionUseCase closeConnectionUseCase,
      required NavigatorState navigator})
      : clipboardDependencies = ClipboardViewModelDependencies(
            dataTransceiver: dataTransceiver,
            closeConnectionUseCase: closeConnectionUseCase,
            navigator: navigator);

  final ClipboardViewModelDependencies clipboardDependencies;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final provider = clipboardViewModelProvider(clipboardDependencies);
    final AsyncValue<String> state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        viewModel.onBackPressed(context);
      },
      child: Scaffold(
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
                  btn.IconButton(viewModel: viewModel.copyButtonViewModel),
                  btn.IconButton(viewModel: viewModel.pasteButtonViewModel),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
