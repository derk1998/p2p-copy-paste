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
        return Center(
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
                  btn.Button(viewModel: viewModel.copyButtonViewModel),
                  btn.Button(viewModel: viewModel.pasteButtonViewModel),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
