import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/connect_dialog.dart';
import 'package:p2p_copy_paste/widgets/pure_icon_button.dart';

class ConnectDialog extends ScreenView<ConnectDialogViewModel> {
  const ConnectDialog({super.key, required super.viewModel});

  @override
  State<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState
    extends ScreenViewState<ConnectDialog, ConnectDialogViewModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectDialogState>(
      stream: viewModel.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text(viewModel.title())),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: !snapshot.hasData || snapshot.data!.loading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(snapshot.data!.description),
                        const SizedBox(
                          height: 16,
                        ),
                        if (snapshot.data!.refreshButtonViewModel != null)
                          PureIconButton(
                              viewModel: snapshot.data!.refreshButtonViewModel!)
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
