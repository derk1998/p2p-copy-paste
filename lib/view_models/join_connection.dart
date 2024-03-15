import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/screens/clipboard.dart';
import 'package:test_webrtc/services/join_connection.dart';
import 'package:test_webrtc/view_models/button.dart';

class JoinConnectionScreenViewModel
    extends AutoDisposeFamilyAsyncNotifier<String, NavigatorState> {
  late NavigatorState _navigator;
  final String title = 'Join connection';
  final codeController = TextEditingController();
  late ButtonViewModel connectButtonViewModel;

  void dispose() {
    codeController.dispose();
  }

  @override
  FutureOr<String> build(NavigatorState arg) {
    ref.onDispose(dispose);
    _navigator = arg;
    connectButtonViewModel = ButtonViewModel(
        title: 'Connect', onPressed: _onSubmitConnectionIdButtonClicked);
    return '';
  }

  void _onSubmitConnectionIdButtonClicked() async {
    if (codeController.text.trim().isEmpty) {
      state = const AsyncData('ID must be valid');
      return;
    }

    final connectionService = ref.read(joinConnectionServiceProvider);

    connectionService.setOnConnectedListener(() {
      _navigator.push(MaterialPageRoute(
        builder: (context) => ClipboardScreen(
          closeConnectionUseCase: connectionService,
          dataTransceiver: connectionService,
          navigator: _navigator,
        ),
      ));
    });

    try {
      state = const AsyncLoading();
      await connectionService.joinConnection(codeController.text);
    } catch (e) {
      state = const AsyncData('Unable to connect. Is the ID correct?');
    }
  }
}

final joinConnectionScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<JoinConnectionScreenViewModel,
        String, NavigatorState>(() {
  return JoinConnectionScreenViewModel();
});
