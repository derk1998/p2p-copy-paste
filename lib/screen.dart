import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

class Screen {
  Screen({required this.view, required this.viewModel});

  Widget view;
  ScreenViewModel viewModel;
}
