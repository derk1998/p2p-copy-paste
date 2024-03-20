import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/models/invite.dart';
import 'package:test_webrtc/screens/clipboard.dart';
import 'package:test_webrtc/services/create_connection.dart';
import 'package:test_webrtc/services/create_invite.dart';
import 'package:test_webrtc/view_models/button.dart';

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
    final result = await ref.read(createInviteServiceProvider).accept(invite);

    if (result) {
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
      connectionService.startNewConnection();
    } else {
      log('FAILED TO JOIN');
    }
  }

  void _onDeclineInviteButtonPressed() {
    ref.read(createInviteServiceProvider).decline(invite);
    Navigator.pop(navigator.context);
  }
}
