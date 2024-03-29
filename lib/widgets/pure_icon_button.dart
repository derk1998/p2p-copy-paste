import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class PureIconButton extends IconButton {
  PureIconButton({super.key, required PureIconButtonViewModel viewModel})
      : super(onPressed: viewModel.onPressed, icon: Icon(viewModel.icon));
}
