import 'package:flutter/material.dart';
import 'package:test_webrtc/view_models/invite_expired.dart';
import 'package:test_webrtc/widgets/pure_icon_button.dart';

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
