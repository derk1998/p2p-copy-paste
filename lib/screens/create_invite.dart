import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/create_invite.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateInviteScreen extends StatefulWidget {
  const CreateInviteScreen({super.key, required this.viewModel});

  final CreateInviteScreenViewModel viewModel;

  @override
  State<CreateInviteScreen> createState() => _CreateInviteScreenState();
}

class _CreateInviteScreenState extends State<CreateInviteScreen> {
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
    return StreamBuilder<CreateInviteScreenState>(
      stream: widget.viewModel.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.viewModel.title),
          ),
          body: Center(
            child: !snapshot.hasData || snapshot.data!.loading
                ? const CircularProgressIndicator()
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    if (kDebugMode && snapshot.data!.data != null)
                      SelectableText(snapshot.data!.data!),
                    if (snapshot.data!.data != null)
                      QrImageView(
                        data: snapshot.data!.data!,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    if (snapshot.data!.seconds != null)
                      Text(
                        snapshot.data!.seconds!.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                  ]),
          ),
        );
      },
    );
  }
}
