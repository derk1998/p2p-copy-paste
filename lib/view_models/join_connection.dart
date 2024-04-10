import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/screens/connect_dialog.dart';
import 'package:p2p_copy_paste/screens/join_connection.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class JoinConnectionScreenViewModel
    extends AutoDisposeFamilyAsyncNotifier<String, NavigatorState> {
  final codeController = TextEditingController();
  late ButtonViewModel connectButtonViewModel;
  late NavigatorState _navigator;
  final String title = 'Join connection';

  void _dispose() {
    codeController.dispose();
  }

  @override
  FutureOr<String> build(NavigatorState arg) {
    connectButtonViewModel = ButtonViewModel(
        title: 'Connect', onPressed: _onSubmitConnectionIdButtonClicked);
    ref.onDispose(_dispose);
    _navigator = arg;
    return '';
  }

  void _onSubmitConnectionIdButtonClicked() async {
    final invite = Invite(codeController.text);
    //First some sanity checking
    state = const AsyncLoading();

    if (invite.creator.trim().isEmpty) {
      state = const AsyncData('ID must be valid');
      return;
    }

    _navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => ConnectDialog(
          invite: invite,
          navigator: _navigator,
          getJoinNewInvitePageView: () => const JoinConnectionScreen(),
        ),
      ),
    );
  }
}

final joinConnectionScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<JoinConnectionScreenViewModel,
        String, NavigatorState>(() {
  return JoinConnectionScreenViewModel();
});
