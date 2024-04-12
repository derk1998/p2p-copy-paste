import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/create_invite.dart';
import 'package:p2p_copy_paste/screens/join_connection.dart';
import 'package:p2p_copy_paste/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/create_invite.dart';
import 'package:p2p_copy_paste/view_models/join_connection.dart';
import 'package:p2p_copy_paste/view_models/scan_qr_code.dart';

class HomeScreenViewModel {
  HomeScreenViewModel(GetIt serviceLocator)
      : navigator = serviceLocator.get<INavigator>(),
        clipboardService = serviceLocator.get<IClipboardService>(),
        createInviteService = serviceLocator.get<ICreateInviteService>(),
        createConnectionService =
            serviceLocator.get<ICreateConnectionService>(),
        joinConnectionService = serviceLocator.get<IJoinConnectionService>(),
        joinInviteService = serviceLocator.get<IJoinInviteService>() {
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

  final INavigator navigator;
  final IClipboardService clipboardService;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  final IJoinConnectionService joinConnectionService;
  final IJoinInviteService joinInviteService;

  late ButtonViewModel startNewConnectionButtonViewModel;
  ButtonViewModel? joinConnectionButtonViewModel;
  IconButtonViewModel? joinWithQrCodeButtonViewModel;
  final String description =
      'Start copying and pasting between devices. Download the app or go to https://cp.xdatwork.com on your other device.';

  void _onCreateInviteButtonClicked() async {
    navigator.pushScreen(CreateInviteScreen(
      viewModel: CreateInviteScreenViewModel(
        navigator: navigator,
        createInviteService: createInviteService,
        createConnectionService: createConnectionService,
        clipboardService: clipboardService,
      ),
    ));
  }

  void _onJoinWithQrCodeButtonClicked() {
    navigator.pushScreen(
      ScanQRCodeScreen(
        viewModel: ScanQrCodeScreenViewModel(
          navigator: navigator,
          clipboardService: clipboardService,
          joinConnectionService: joinConnectionService,
          joinInviteService: joinInviteService,
        ),
      ),
    );
  }

  void _onJoinConnectionButtonClicked() {
    navigator.pushScreen(
      JoinConnectionScreen(
        viewModel: JoinConnectionScreenViewModel(
          clipboardService: clipboardService,
          joinConnectionService: joinConnectionService,
          joinInviteService: joinInviteService,
          navigator: navigator,
        ),
      ),
    );
  }
}
