import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class ClipboardScreen extends StatefulWidget {
  const ClipboardScreen({super.key, required this.viewModel});

  final ClipboardScreenViewModel viewModel;

  @override
  State<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState extends State<ClipboardScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClipboardScreenState>(
      stream: widget.viewModel.state,
      builder: (context, snapshot) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            widget.viewModel.onBackPressed();
          },
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (snapshot.hasData) Text(snapshot.data!.clipboard),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      btn.IconButton(
                          viewModel: widget.viewModel.copyButtonViewModel),
                      btn.IconButton(
                          viewModel: widget.viewModel.pasteButtonViewModel),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
