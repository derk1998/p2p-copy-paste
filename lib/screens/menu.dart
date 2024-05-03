import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class MenuScreen extends ScreenView<MenuScreenViewModel> {
  const MenuScreen({super.key, required super.viewModel});

  @override
  State<MenuScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState
    extends ScreenViewState<MenuScreen, MenuScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.viewModel.description,
              textAlign: TextAlign.center,
            ),
            for (final buttonViewModel in viewModel.buttonViewModelList)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: btn.IconButton(
                  viewModel: buttonViewModel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
