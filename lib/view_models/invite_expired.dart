import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/create_invite.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/create_invite.dart';

class InviteExpiredViewModel {
  InviteExpiredViewModel(
      {required this.navigator,
      required this.createInviteService,
      required this.createConnectionService}) {
    iconButtonViewModel = PureIconButtonViewModel(
      icon: Icons.refresh,
      onPressed: _pushCreateInviteScreen,
    );
  }

  final INavigator navigator;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;

  final String title = 'Invite has expired';
  final String description =
      'Your invite has expired. Do you want to create a new one?';
  late PureIconButtonViewModel iconButtonViewModel;

  void _pushCreateInviteScreen() {
    navigator.replaceScreen(CreateInviteScreen(
      viewModel: CreateInviteScreenViewModel(
          navigator: navigator,
          createInviteService: createInviteService,
          createConnectionService: createConnectionService),
    ));
  }
}
