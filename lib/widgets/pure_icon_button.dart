import 'package:flutter/material.dart';
import 'package:test_webrtc/view_models/button.dart';

class PureIconButton extends IconButton {
  PureIconButton({super.key, required PureIconButtonViewModel viewModel})
      : super(onPressed: viewModel.onPressed, icon: Icon(viewModel.icon));
}
