import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

abstract class ScreenView<VM extends StatefulScreenViewModel>
    extends StatefulWidget {
  const ScreenView({super.key, required this.viewModel});

  final VM viewModel;
}

abstract class ScreenViewState<V extends ScreenView<VM>,
    VM extends StatefulScreenViewModel> extends State<V> {
  VM get viewModel => widget.viewModel;

  @mustCallSuper
  @override
  void initState() {
    widget.viewModel.init();
    super.initState();
  }

  @mustCallSuper
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }
}
