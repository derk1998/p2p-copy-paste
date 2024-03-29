import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/models/invite.dart';
import 'package:test_webrtc/screens/clipboard.dart';
import 'package:test_webrtc/services/join_connection.dart';
import 'package:test_webrtc/services/join_invite.dart';

abstract class AbstractJoinConnectionScreenViewModel<T>
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

  void join(Invite invite) async {
    state = const AsyncLoading();

    if (invite.creator.trim().isEmpty) {
      state = const AsyncData('ID must be valid');
      return;
    }

    bool result = await ref.read(joinInviteServiceProvider).join(invite);

    if (!result) {
      state = const AsyncData('Could not join');
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
      await connectionService.joinConnection(invite.creator);
    } catch (e) {
      state = const AsyncData('Unable to connect. Is the ID correct?');
    }
  }
}
