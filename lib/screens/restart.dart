import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';
import 'package:p2p_copy_paste/widgets/button.dart' as btn;

class RestartScreen extends StatelessScreenView<RestartViewModel> {
  const RestartScreen({super.key, required super.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(viewModel.description),
          btn.Button(viewModel: viewModel.iconButtonViewModel)
        ],
      ),
    );
  }
}
