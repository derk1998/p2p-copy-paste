import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/basic.dart';

class CenteredDescriptionScreen extends ScreenView<BasicViewModel> {
  const CenteredDescriptionScreen({super.key, required super.viewModel});

  @override
  State<CenteredDescriptionScreen> createState() => _ConnectDialogState();
}

class _ConnectDialogState
    extends ScreenViewState<CenteredDescriptionScreen, BasicViewModel> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(viewModel.description));
  }
}
