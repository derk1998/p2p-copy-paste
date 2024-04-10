import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/create_invite.dart';
import 'package:p2p_copy_paste/screens/join_connection.dart';
import 'package:p2p_copy_paste/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/create_invite.dart';

class HomeScreenViewModel {
  HomeScreenViewModel() {
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

  late ButtonViewModel startNewConnectionButtonViewModel;
  ButtonViewModel? joinConnectionButtonViewModel;
  IconButtonViewModel? joinWithQrCodeButtonViewModel;
  final String description =
      'Start copying and pasting between devices. Download the app or go to https://cp.xdatwork.com on your other device.';

  void _onCreateInviteButtonClicked() async {
    GetIt.I.get<INavigator>().pushScreen(CreateInviteScreen(
          viewModel: CreateInviteScreenViewModel(
              navigator: GetIt.I.get<INavigator>(),
              createInviteService: GetIt.I.get<ICreateInviteService>(),
              createConnectionService: GetIt.I.get<ICreateConnectionService>()),
        ));
  }

  void _onJoinWithQrCodeButtonClicked() {
    GetIt.I.get<INavigator>().pushScreen(const ScanQRCodeScreen());
  }

  void _onJoinConnectionButtonClicked() {
    GetIt.I.get<INavigator>().pushScreen(const JoinConnectionScreen());
  }
}

final homeScreenViewModelProvider = Provider<HomeScreenViewModel>((ref) {
  return HomeScreenViewModel();
});
