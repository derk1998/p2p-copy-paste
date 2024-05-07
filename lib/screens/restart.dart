import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class RestartScreen extends ScreenView<RestartViewModel> {
  const RestartScreen({super.key, required super.viewModel});

  @override
  State<RestartScreen> createState() => _InviteExpiredScreenState();
}

class _InviteExpiredScreenState
    extends ScreenViewState<RestartScreen, RestartViewModel> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.viewModel.description),
          btn.Button(viewModel: widget.viewModel.iconButtonViewModel)
        ],
      ),
    );
  }
}
