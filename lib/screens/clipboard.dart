import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class ClipboardScreen extends ScreenView<ClipboardScreenViewModel> {
  const ClipboardScreen({super.key, required super.viewModel});

  @override
  State<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState
    extends ScreenViewState<ClipboardScreen, ClipboardScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClipboardScreenState>(
      stream: viewModel.state,
      builder: (context, snapshot) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            viewModel.onBackPressed();
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
                      btn.IconButton(viewModel: viewModel.copyButtonViewModel),
                      btn.IconButton(viewModel: viewModel.pasteButtonViewModel),
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
