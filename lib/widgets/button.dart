import 'package:flutter/material.dart';
import 'package:test_webrtc/view_models/button.dart';

class Button extends ElevatedButton {
  Button({super.key, required ButtonViewModel viewModel})
      : super(child: Text(viewModel.title), onPressed: viewModel.onPressed);
}

//Wrap ElevatedButton.icon because it's not possible to extend like
// a normal ElevatedButton
class IconButton extends StatelessWidget {
  const IconButton({super.key, required this.viewModel});

  final IconButtonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: viewModel.onPressed,
        icon: Icon(viewModel.icon),
        label: Text(viewModel.title));
  }
}
