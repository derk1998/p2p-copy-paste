import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/view_models/connect_existing_peer.dart';

class ConnectExistingPeer extends ConsumerStatefulWidget {
  const ConnectExistingPeer({super.key});

  @override
  ConsumerState<ConnectExistingPeer> createState() =>
      _ConnectExistingPeerState();
}

class _ConnectExistingPeerState extends ConsumerState<ConnectExistingPeer> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String> state =
        ref.watch(connectToExistingPeerViewModelProvider);
    final viewModel = ref.read(connectToExistingPeerViewModelProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _codeController,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () async {
                  viewModel
                      .onSubmitConnectionIdButtonClicked(_codeController.text);
                },
                child: const Text('Connect'),
              ),
              const SizedBox(
                height: 16,
              ),
              state.isLoading
                  ? const Text('Loading')
                  : Text(state.value == null ? 'no data' : state.value!)
            ],
          ),
        ),
      ),
    );
  }
}
