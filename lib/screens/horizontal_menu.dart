import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class HorizontalMenuScreen extends ScreenView<MenuScreenViewModel> {
  const HorizontalMenuScreen({super.key, required super.viewModel});

  @override
  State<HorizontalMenuScreen> createState() => _HorizontalMenuScreenState();
}

class _HorizontalMenuScreenState
    extends ScreenViewState<HorizontalMenuScreen, MenuScreenViewModel> {
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
