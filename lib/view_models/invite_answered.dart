import 'package:flutter/material.dart';
import 'package:test_webrtc/models/invite.dart';
import 'package:test_webrtc/view_models/button.dart';

class InviteAnsweredScreenViewModel {
  InviteAnsweredScreenViewModel(
      {required this.invite, required this.navigator}) {
    description =
        'Your invite has been answered. Did you accept the invite with code: ${invite.joiner!}?';
    acceptInviteButton =
        ButtonViewModel(title: 'Yes', onPressed: _onAcceptInviteButtonPressed);
    declineInviteButton =
        ButtonViewModel(title: 'No', onPressed: _onDeclineInviteButtonPressed);
  }

  final Invite invite;
  final String title = 'Invite answered';
  late String description;
  final NavigatorState navigator;
  late ButtonViewModel acceptInviteButton;
  late ButtonViewModel declineInviteButton;

  void _onAcceptInviteButtonPressed() {
    //todo: establish connection
  }

  void _onDeclineInviteButtonPressed() {
    Navigator.pop(navigator.context);
  }
}
