import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/create_invite/view_models/invite_answered.dart';
import 'package:p2p_copy_paste/widgets/button.dart';

class InviteAnsweredScreen extends ScreenView<InviteAnsweredScreenViewModel> {
  const InviteAnsweredScreen({super.key, required super.viewModel});

  @override
  State<InviteAnsweredScreen> createState() => _InviteAnsweredScreenState();
}

class _InviteAnsweredScreenState extends ScreenViewState<InviteAnsweredScreen,
    InviteAnsweredScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.viewModel.description),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(viewModel: widget.viewModel.acceptInviteButton),
              const SizedBox(
                width: 8,
              ),
              Button(viewModel: widget.viewModel.declineInviteButton)
            ],
          )
        ],
      ),
    );
  }
}
