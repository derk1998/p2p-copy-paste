import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/view_models/connect_to_peer.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ConnectToPeerScreen extends ConsumerWidget {
  const ConnectToPeerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ConnectToPeerData> state =
        ref.watch(connectToPeerViewModelProvider);
    final viewModel = ref.read(connectToPeerViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight / 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed:
                                viewModel.onStartNewConnectionButtonClicked,
                            child: const Text('Initiate connection'),
                          ),
                          ElevatedButton(
                            onPressed:
                                viewModel.onConnectToExistingPeerButtonClicked,
                            child: const Text('Connect to existing peer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Column(children: [
              state.isLoading
                  ? const Text('Loading')
                  : Text(state.value == null
                      ? 'no data'
                      : state.value!.statusText),
              if (state.value != null && state.value!.connectionId != null)
                SelectableText(state.value!.connectionId!),
              if (state.value != null && state.value!.connectionId != null)
                QrImageView(
                  data: state.value!.connectionId!,
                  version: QrVersions.auto,
                  size: 200.0,
                )
            ]),
          )
        ],
      ),
    );
  }
}
