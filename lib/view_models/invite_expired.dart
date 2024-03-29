import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screens/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class InviteExpiredViewModel {
  InviteExpiredViewModel({required this.navigator}) {
    iconButtonViewModel = PureIconButtonViewModel(
      icon: Icons.refresh,
      onPressed: _pushCreateInviteScreen,
    );
  }

  final NavigatorState navigator;

  final String title = 'Invite has expired';
  final String description =
      'Your invite has expired. Do you want to create a new one?';
  late PureIconButtonViewModel iconButtonViewModel;

  void _pushCreateInviteScreen() {
    navigator.pushReplacement(MaterialPageRoute(
      builder: (context) => const CreateInviteScreen(),
    ));
  }
}
