import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/view_models/create_invite.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateInviteScreen extends ConsumerWidget {
  const CreateInviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider =
        createInviteScreenViewModelProvider(Navigator.of(context));
    final AsyncValue<CreateInviteScreenData> state =
        ref.watch(viewModelProvider);

    final viewModel = ref.read(viewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
      ),
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : Column(mainAxisSize: MainAxisSize.min, children: [
                if (state.value != null && state.value!.data != null)
                  SelectableText(state.value!.data!),
                if (state.value != null && state.value!.data != null)
                  QrImageView(
                    data: state.value!.data!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                if (state.value?.seconds != null)
                  Text(
                    state.value!.seconds!.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
              ]),
      ),
    );
  }
}
