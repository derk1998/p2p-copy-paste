import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/view_models/abstract_join_connection.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class JoinConnectionScreenViewModel
    extends AbstractJoinConnectionScreenViewModel {
  final codeController = TextEditingController();
  late ButtonViewModel connectButtonViewModel;

  @override
  void dispose() {
    codeController.dispose();
  }

  @override
  FutureOr<String> build(NavigatorState arg) {
    connectButtonViewModel = ButtonViewModel(
        title: 'Connect', onPressed: _onSubmitConnectionIdButtonClicked);
    return super.build(arg);
  }

  void _onSubmitConnectionIdButtonClicked() async {
    final invite = Invite(codeController.text);
    join(invite);
  }
}

final joinConnectionScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<JoinConnectionScreenViewModel,
        String, NavigatorState>(() {
  return JoinConnectionScreenViewModel();
});
