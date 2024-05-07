import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class VerticalMenuScreen extends StatelessScreenView<MenuScreenViewModel> {
  const VerticalMenuScreen({super.key, required super.viewModel});

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
            for (final buttonViewModel in viewModel.buttonViewModelList)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: btn.Button(
                  viewModel: buttonViewModel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
