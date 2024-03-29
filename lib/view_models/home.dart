import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/screens/create_invite.dart';
import 'package:test_webrtc/screens/join_connection.dart';
import 'package:test_webrtc/screens/scan_qr_code.dart';
import 'package:test_webrtc/view_models/button.dart';

class HomeScreenViewModel {
  HomeScreenViewModel({required this.navigator}) {
    startNewConnectionButtonViewModel = ButtonViewModel(
        title: 'Create an invite', onPressed: _onCreateInviteButtonClicked);

    if (kDebugMode) {
      joinConnectionButtonViewModel = ButtonViewModel(
          title: 'I have a code', onPressed: _onJoinConnectionButtonClicked);
    }

    if (!kIsWeb) {
      //not supported for web
      joinWithQrCodeButtonViewModel = IconButtonViewModel(
          title: 'I have a QR code',
          onPressed: _onJoinWithQrCodeButtonClicked,
          icon: Icons.qr_code);
    }
  }

  final NavigatorState navigator;
  late ButtonViewModel startNewConnectionButtonViewModel;
  ButtonViewModel? joinConnectionButtonViewModel;
  IconButtonViewModel? joinWithQrCodeButtonViewModel;

  void _onCreateInviteButtonClicked() async {
    navigator.push(MaterialPageRoute(
      builder: (context) => const CreateInviteScreen(),
    ));
  }

  void _onJoinWithQrCodeButtonClicked() {
    navigator.push(MaterialPageRoute(
      builder: (context) => const ScanQRCodeScreen(),
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
