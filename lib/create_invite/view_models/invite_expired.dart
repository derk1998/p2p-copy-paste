import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

class InviteExpiredViewModel extends ScreenViewModel {
  InviteExpiredViewModel(
      {required this.restartCondition, required this.createInviteService}) {
    iconButtonViewModel = PureIconButtonViewModel(
      icon: Icons.refresh,
      onPressed: _pushCreateInviteScreen,
    );
  }

  final StreamController<bool> restartCondition;
  final ICreateInviteService createInviteService;

  final String description =
      'Your invite has expired. Do you want to create a new one?';
  late PureIconButtonViewModel iconButtonViewModel;

  void _pushCreateInviteScreen() {
    restartCondition.add(true);
  }

  @override
  void dispose() {}

  @override
  void init() {}

  @override
  String getTitle() {
    return 'Invite has expired';
  }
}
