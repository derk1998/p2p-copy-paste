import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/create/view_models/create_invite.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateInviteScreen extends ScreenView<CreateInviteScreenViewModel> {
  const CreateInviteScreen({super.key, required super.viewModel});

  @override
  State<CreateInviteScreen> createState() => _CreateInviteScreenState();
}

class _CreateInviteScreenState
    extends ScreenViewState<CreateInviteScreen, CreateInviteScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CreateInviteScreenState>(
      stream: viewModel.state,
      builder: (context, snapshot) {
        return Center(
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
                  ]));
      },
    );
  }
}
