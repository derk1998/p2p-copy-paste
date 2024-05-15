import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/view_models/basic.dart';

class CenteredDescriptionScreen extends StatelessScreenView<BasicViewModel> {
  const CenteredDescriptionScreen({super.key, required super.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(viewModel.description));
  }
}
