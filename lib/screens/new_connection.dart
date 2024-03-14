import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/view_models/new_connection.dart';
import 'package:qr_flutter/qr_flutter.dart';

class NewConnectionScreen extends ConsumerWidget {
  const NewConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider =
        newConnectionScreenViewModelProvider(Navigator.of(context));
    final AsyncValue<NewConnectionScreenData> state =
        ref.watch(viewModelProvider);

    final viewModel = ref.read(viewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          state.isLoading
              ? const Text('Loading')
              : Text(state.value == null ? 'no data' : state.value!.statusText),
          if (state.value != null && state.value!.connectionId != null)
            SelectableText(state.value!.connectionId!),
          if (state.value != null && state.value!.connectionId != null)
            QrImageView(
              data: state.value!.connectionId!,
              version: QrVersions.auto,
              size: 200.0,
            )
        ]),
      ),
    );
  }
}
