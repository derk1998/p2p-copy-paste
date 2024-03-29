import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/widgets/button.dart';

class CancelConfirmDialog extends StatelessWidget {
  const CancelConfirmDialog({super.key, required this.viewModel});

  final CancelConfirmViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(viewModel.title),
      content: Text(
        viewModel.description,
      ),
      actions: <Widget>[
        DialogButton(viewModel: viewModel.confirmButtonViewModel),
        DialogButton(viewModel: viewModel.cancelButtonViewModel),
      ],
    );
  }
}
