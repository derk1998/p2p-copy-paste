import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class InviteAnsweredScreenViewModel {
  InviteAnsweredScreenViewModel(
      {required this.invite, required this.navigator, required this.ref}) {
    description =
        'Your invite has been answered. Did you accept the invite with code: ${invite.joiner!}?';
    acceptInviteButton =
        ButtonViewModel(title: 'Yes', onPressed: _onAcceptInviteButtonPressed);
    declineInviteButton =
        ButtonViewModel(title: 'No', onPressed: _onDeclineInviteButtonPressed);
  }

  final Invite invite;
  final Ref ref;
  final String title = 'Invite answered';
  late String description;
  final NavigatorState navigator;
  late ButtonViewModel acceptInviteButton;
  late ButtonViewModel declineInviteButton;

  void _onAcceptInviteButtonPressed() async {
    final connectionService = ref.read(createConnectionServiceProvider);
    connectionService.setOnConnectedListener(() {
      navigator.push(MaterialPageRoute(
        builder: (context) => ClipboardScreen(
          closeConnectionUseCase: connectionService,
          dataTransceiver: connectionService,
          navigator: navigator,
        ),
      ));
    });
    await connectionService.startNewConnection();

    final result = await ref.read(createInviteServiceProvider).accept(invite);
    if (!result) {
      connectionService.close();
    }
  }

  void _onDeclineInviteButtonPressed() {
    ref.read(createInviteServiceProvider).decline(invite);
    Navigator.pop(navigator.context);
  }
}
