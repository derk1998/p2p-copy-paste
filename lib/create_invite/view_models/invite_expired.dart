import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/create_invite/screens/create_invite.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/create_invite/view_models/create_invite.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

class InviteExpiredViewModel extends ScreenViewModel {
  InviteExpiredViewModel(
      {required this.navigator,
      required this.createInviteService,
      required this.createConnectionService,
      required this.clipboardService}) {
    iconButtonViewModel = PureIconButtonViewModel(
      icon: Icons.refresh,
      onPressed: _pushCreateInviteScreen,
    );
  }

  final INavigator navigator;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  final IClipboardService clipboardService;

  final String description =
      'Your invite has expired. Do you want to create a new one?';
  late PureIconButtonViewModel iconButtonViewModel;

  void _pushCreateInviteScreen() {
    navigator.replaceScreen(CreateInviteScreen(
      viewModel: CreateInviteScreenViewModel(
          navigator: navigator,
          createInviteService: createInviteService,
          createConnectionService: createConnectionService,
          clipboardService: clipboardService),
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void init() {
    // TODO: implement init
  }

  @override
  String title() {
    return 'Invite has expired';
  }
}
