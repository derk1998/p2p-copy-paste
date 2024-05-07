import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

class RestartViewModel extends ScreenViewModel {
  RestartViewModel(
      {required this.title,
      required this.restartCondition,
      required this.description}) {
    iconButtonViewModel = ButtonViewModel(
      icon: Icons.refresh,
      onPressed: _pushCreateInviteScreen,
    );
  }

  final StreamController<bool> restartCondition;

  final String title;
  final String description;
  late ButtonViewModel iconButtonViewModel;

  void _pushCreateInviteScreen() {
    restartCondition.add(true);
  }

  @override
  String getTitle() {
    return title;
  }
}
