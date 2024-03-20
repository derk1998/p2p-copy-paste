import 'package:flutter/material.dart';
import 'package:test_webrtc/view_models/invite_answered.dart';
import 'package:test_webrtc/widgets/button.dart';

class InviteAnsweredScreen extends StatelessWidget {
  const InviteAnsweredScreen({super.key, required this.viewModel});

  final InviteAnsweredScreenViewModel viewModel;

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
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(viewModel: viewModel.acceptInviteButton),
                const SizedBox(
                  width: 8,
                ),
                Button(viewModel: viewModel.declineInviteButton)
              ],
            )
          ],
        ),
      ),
    );
  }
}
