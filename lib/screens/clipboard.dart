import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class ClipboardScreen extends StatefulScreenView<ClipboardScreenViewModel> {
  const ClipboardScreen({super.key, required super.viewModel});

  @override
  State<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState
    extends StatefulScreenViewState<ClipboardScreen, ClipboardScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClipboardScreenState>(
      stream: viewModel.state,
      builder: (context, snapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FractionallySizedBox(
                  heightFactor: 0.75,
                  child: Center(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        snapshot.hasData ? snapshot.data!.clipboard : '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                btn.Button(viewModel: viewModel.copyButtonViewModel),
                const SizedBox(width: 8),
                btn.Button(viewModel: viewModel.pasteButtonViewModel),
              ],
            )
          ],
        );
      },
    );
  }
}
