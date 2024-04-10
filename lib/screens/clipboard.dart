import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/use_cases/close_connection.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class ClipboardScreen extends ConsumerWidget {
  ClipboardScreen(
      {super.key,
      required TransceiveDataUseCase dataTransceiver,
      required CloseConnectionUseCase closeConnectionUseCase})
      : clipboardDependencies = ClipboardViewModelDependencies(
            dataTransceiver: dataTransceiver,
            closeConnectionUseCase: closeConnectionUseCase);

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
