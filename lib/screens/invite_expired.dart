import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/invite_expired.dart';
import 'package:p2p_copy_paste/widgets/pure_icon_button.dart';

class InviteExpiredScreen extends StatelessWidget {
  const InviteExpiredScreen({super.key, required this.viewModel});

  final InviteExpiredViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.description),
            PureIconButton(viewModel: viewModel.iconButtonViewModel)
          ],
        ),
      ),
    );
  }
}
