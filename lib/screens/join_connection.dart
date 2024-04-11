import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/join_connection.dart';
import 'package:p2p_copy_paste/widgets/button.dart';

class JoinConnectionScreen extends StatefulWidget {
  const JoinConnectionScreen({super.key, required this.viewModel});

  final JoinConnectionScreenViewModel viewModel;

  @override
  State<JoinConnectionScreen> createState() => _JoinConnectionScreenState();
}

class _JoinConnectionScreenState extends State<JoinConnectionScreen> {
  final codeController = TextEditingController();

  @override
  void initState() {
    widget.viewModel.init();
    codeController.addListener(() {
      widget.viewModel.code = codeController.text;
    });
    super.initState();
  }

  @override
  void dispose() {
    codeController.dispose();
    widget.viewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<JoinConnectionScreenState>(
      stream: widget.viewModel.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.viewModel.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Button(viewModel: widget.viewModel.connectButtonViewModel),
                  const SizedBox(
                    height: 16,
                  ),
                  !snapshot.hasData || snapshot.data!.loading
                      ? const CircularProgressIndicator()
                      : Text(snapshot.data!.status)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
