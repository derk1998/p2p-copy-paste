import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/join/view_models/join_connection.dart';
import 'package:p2p_copy_paste/widgets/button.dart';

class JoinConnectionScreen
    extends StatefulScreenView<JoinConnectionScreenViewModel> {
  const JoinConnectionScreen({super.key, required super.viewModel});

  @override
  State<JoinConnectionScreen> createState() => _JoinConnectionScreenState();
}

class _JoinConnectionScreenState extends StatefulScreenViewState<
    JoinConnectionScreen, JoinConnectionScreenViewModel> {
  final codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    codeController.addListener(() {
      viewModel.code = codeController.text;
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<JoinConnectionScreenState>(
      stream: viewModel.state,
      builder: (context, snapshot) {
        return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                ),
                const SizedBox(
                  height: 16,
                ),
                Button(viewModel: viewModel.connectButtonViewModel),
                const SizedBox(
                  height: 16,
                ),
                !snapshot.hasData || snapshot.data!.loading
                    ? const CircularProgressIndicator()
                    : Text(snapshot.data!.status)
              ],
            )));
      },
    );
  }
}
