import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/screens/join_connection.dart';
import 'package:test_webrtc/screens/new_connection.dart';
import 'package:test_webrtc/view_models/button.dart';

class HomeScreenViewModel {
  HomeScreenViewModel({required this.navigator}) {
    startNewConnectionButtonViewModel = ButtonViewModel(
        title: 'Start new connection',
        onPressed: _onStartNewConnectionButtonClicked);

    joinConnectionButtonViewModel = ButtonViewModel(
        title: 'Join connection', onPressed: _onJoinConnectionButtonClicked);
  }

  final NavigatorState navigator;
  final String title = 'P2P Copy Paste';
  late ButtonViewModel startNewConnectionButtonViewModel;
  late ButtonViewModel joinConnectionButtonViewModel;

  void _onStartNewConnectionButtonClicked() async {
    navigator.push(MaterialPageRoute(
      builder: (context) => const NewConnectionScreen(),
    ));
  }

  void _onJoinConnectionButtonClicked() {
    navigator.push(MaterialPageRoute(
      builder: (context) => const JoinConnectionScreen(),
    ));
  }
}

final homeScreenViewModelProvider =
    Provider.family<HomeScreenViewModel, NavigatorState>((ref, navigator) {
  return HomeScreenViewModel(navigator: navigator);
});
