import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/screens/clipboard.dart';
import 'package:test_webrtc/services/create_connection.dart';

class NewConnectionScreenData {
  NewConnectionScreenData({required this.statusText, this.connectionId});

  final String statusText;
  String? connectionId;
}

class NewConnectionScreenViewModel extends AutoDisposeFamilyAsyncNotifier<
    NewConnectionScreenData, NavigatorState> {
  final String title = 'Create a new connection';

  @override
  FutureOr<NewConnectionScreenData> build(NavigatorState arg) {
    ref.onDispose(() {
      log('DISPOSING NEW CONNECTION VM');
    });
    return _connect(arg);
  }

  Future<NewConnectionScreenData> _connect(NavigatorState navigator) async {
    final completer = Completer<NewConnectionScreenData>();
    final connectionService = ref.read(createConnectionServiceProvider);
    state = const AsyncLoading();

    connectionService.setOnConnectedListener(() {
      navigator.push(MaterialPageRoute(
        builder: (context) => ClipboardScreen(
          dataTransceiver: connectionService,
        ),
      ));
    });

    connectionService.setOnConnectionIdPublished((id) {
      completer.complete(NewConnectionScreenData(
          statusText: 'Connection ID:', connectionId: id));
    });
    connectionService.startNewConnection();
    return completer.future;
  }
}

final newConnectionScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<NewConnectionScreenViewModel,
        NewConnectionScreenData, NavigatorState>(() {
  return NewConnectionScreenViewModel();
});
