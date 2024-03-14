import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/navigation.dart';
import 'package:test_webrtc/screens/clipboard.dart';
import 'package:test_webrtc/screens/connect_existing_peer.dart';
import 'package:test_webrtc/services/create_connection_service.dart';

class ConnectToPeerData {
  ConnectToPeerData({required this.statusText, this.connectionId});

  final String statusText;
  String? connectionId;
}

class ConnectToPeerViewModel extends AsyncNotifier<ConnectToPeerData> {
  @override
  FutureOr<ConnectToPeerData> build() {
    return ConnectToPeerData(
        statusText:
            'Start by initiating the connection or joining an existing connection');
  }

  void onStartNewConnectionButtonClicked() async {
    final connectionService = ref.read(createConnectionServiceProvider);
    state = const AsyncLoading();

    connectionService.setOnConnectedListener(() {
      navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => ClipboardScreen(
          dataTransceiver: connectionService,
        ),
      ));
    });

    connectionService.setOnConnectionIdPublished((id) {
      state = AsyncValue.data(
          ConnectToPeerData(statusText: 'Connection ID:', connectionId: id));
    });
    connectionService.startNewConnection();
  }

  void onConnectToExistingPeerButtonClicked() {
    navigatorKey.currentState!.push(MaterialPageRoute(
      builder: (context) => const ConnectExistingPeer(),
    ));
  }
}

final connectToPeerViewModelProvider =
    AsyncNotifierProvider<ConnectToPeerViewModel, ConnectToPeerData>(() {
  return ConnectToPeerViewModel();
});
