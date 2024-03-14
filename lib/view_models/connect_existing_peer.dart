import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/navigation.dart';
import 'package:test_webrtc/screens/clipboard.dart';
import 'package:test_webrtc/services/join_connection_service.dart';

class ConnectToExistingPeerViewModel extends AsyncNotifier<String> {
  @override
  FutureOr<String> build() {
    return '';
  }

  void onSubmitConnectionIdButtonClicked(String connectionId) async {
    if (connectionId.trim().isEmpty) {
      state = const AsyncData('ID must be valid');
      return;
    }

    final connectionService = ref.read(joinConnectionServiceProvider);

    connectionService.setOnConnectedListener(() {
      navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => ClipboardScreen(
          dataTransceiver: connectionService,
        ),
      ));
    });

    try {
      state = const AsyncLoading();
      await connectionService.joinConnection(connectionId);
    } catch (e) {
      state = const AsyncData('Unable to connect. Is the ID correct?');
    }
  }
}

final connectToExistingPeerViewModelProvider =
    AsyncNotifierProvider<ConnectToExistingPeerViewModel, String>(() {
  return ConnectToExistingPeerViewModel();
});
