import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/home.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeScreenViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewModel.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            btn.Button(viewModel: viewModel.startNewConnectionButtonViewModel),
            const SizedBox(
              height: 16,
            ),
            if (viewModel.joinConnectionButtonViewModel != null)
              btn.Button(viewModel: viewModel.joinConnectionButtonViewModel!),
            if (viewModel.joinWithQrCodeButtonViewModel != null) ...[
              const SizedBox(
                height: 16,
              ),
              btn.IconButton(
                  viewModel: viewModel.joinWithQrCodeButtonViewModel!)
            ],
          ],
        ),
      ),
    );
  }
}
