import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/create/view_models/invite_expired.dart';
import 'package:p2p_copy_paste/widgets/pure_icon_button.dart';

class InviteExpiredScreen extends ScreenView<InviteExpiredViewModel> {
  const InviteExpiredScreen({super.key, required super.viewModel});

  @override
  State<InviteExpiredScreen> createState() => _InviteExpiredScreenState();
}

class _InviteExpiredScreenState
    extends ScreenViewState<InviteExpiredScreen, InviteExpiredViewModel> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.viewModel.description),
          PureIconButton(viewModel: widget.viewModel.iconButtonViewModel)
        ],
      ),
    );
  }
}
