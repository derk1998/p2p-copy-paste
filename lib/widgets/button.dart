import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class Button extends StatelessWidget {
  const Button({super.key, required this.viewModel});

  final ButtonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return (viewModel.title != null && viewModel.icon != null)
        ? ElevatedButton.icon(
            onPressed: viewModel.onPressed,
            icon: Icon(viewModel.icon),
            label: Text(viewModel.title!))
        : (viewModel.icon == null)
            ? ElevatedButton(
                onPressed: viewModel.onPressed, child: Text(viewModel.title!))
            : IconButton(
                onPressed: viewModel.onPressed, icon: Icon(viewModel.icon));
  }
}

class DialogButton extends StatelessWidget {
  const DialogButton({super.key, required this.viewModel});

  final ButtonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      onPressed: viewModel.onPressed,
      child: Text(viewModel.title!),
    );
  }
}
