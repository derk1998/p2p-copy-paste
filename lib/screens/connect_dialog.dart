import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/connect_dialog.dart';
import 'package:p2p_copy_paste/widgets/pure_icon_button.dart';

class ConnectDialog extends StatefulWidget {
  const ConnectDialog({super.key, required this.viewModel});

  final ConnectDialogViewModel viewModel;

  @override
  State<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  @override
  void initState() {
    widget.viewModel.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectDialogState>(
      stream: widget.viewModel.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.viewModel.title)),
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
