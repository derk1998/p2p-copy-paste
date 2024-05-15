import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class HorizontalMenuScreen extends StatelessScreenView<MenuScreenViewModel> {
  const HorizontalMenuScreen({super.key, required super.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              for (final buttonViewModel in viewModel.buttonViewModelList)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: btn.Button(
                    viewModel: buttonViewModel,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
