import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/screens/clipboard.dart';
import 'package:test_webrtc/services/join_connection.dart';

abstract class AbstractJoinConnectionScreenViewModel
    extends AutoDisposeFamilyAsyncNotifier<String, NavigatorState> {
  late NavigatorState _navigator;
  final String title = 'Join connection';

  void dispose();

  @override
  FutureOr<String> build(NavigatorState arg) {
    ref.onDispose(dispose);
    _navigator = arg;
    return '';
  }

  void join(String id) async {
    if (id.trim().isEmpty) {
      state = const AsyncData('ID must be valid');
      return;
    }

    state = const AsyncData('Connecting...');

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
      await connectionService.joinConnection(id);
    } catch (e) {
      state = const AsyncData('Unable to connect. Is the ID correct?');
    }
  }
}
