import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/flow.dart';

class FlowScreen extends ScreenView<FlowScreenViewModel> {
  const FlowScreen({super.key, required super.viewModel});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState
    extends ScreenViewState<FlowScreen, FlowScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FlowScreenState>(
      stream: viewModel.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(snapshot.hasData ? snapshot.data!.title : ''),
          ),
          body: Center(
            child: !snapshot.hasData
                ? const CircularProgressIndicator()
                : snapshot.data!.view,
          ),
        );
      },
    );
  }
}
