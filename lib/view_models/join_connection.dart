import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/models/invite.dart';
import 'package:test_webrtc/services/join_invite.dart';
import 'package:test_webrtc/view_models/abstract_join_connection.dart';
import 'package:test_webrtc/view_models/button.dart';

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
    state = const AsyncLoading();
    final invite = Invite(codeController.text);
    bool result = await ref.read(joinInviteServiceProvider).join(invite);

    //now we should have access to the connection info
    if (result) {
      join(codeController.text);
    }

    if (!result) {
      log('Failed to join!');
      state = const AsyncData('Could not join');
    }
  }
}

final joinConnectionScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<JoinConnectionScreenViewModel,
        String, NavigatorState>(() {
  return JoinConnectionScreenViewModel();
});
