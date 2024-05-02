import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_flow.dart';
import 'package:p2p_copy_paste/join_invite/join_invite_flow.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/screens/flow.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/join_invite/join_invite_service.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/view_models/flow.dart';

class HomeScreenViewModel {
  HomeScreenViewModel(GetIt serviceLocator)
      : navigator = serviceLocator.get<INavigator>(),
        clipboardService = serviceLocator.get<IClipboardService>(),
        createConnectionService =
            serviceLocator.get<ICreateConnectionService>(),
        joinConnectionService = serviceLocator.get<IJoinConnectionService>(),
        authenticationService = serviceLocator.get<IAuthenticationService>(),
        inviteRepository = serviceLocator.get<IInviteRepository>() {
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
  final ICreateConnectionService createConnectionService;
  final IJoinConnectionService joinConnectionService;
  final IAuthenticationService authenticationService;
  final IInviteRepository inviteRepository;
  Invite? _invite;

  late ButtonViewModel startNewConnectionButtonViewModel;
  ButtonViewModel? joinConnectionButtonViewModel;
  IconButtonViewModel? joinWithQrCodeButtonViewModel;
  final String description =
      'Start copying and pasting between devices. Download the app or go to https://cp.xdatwork.com on your other device.';

  void _onCreateInviteButtonClicked() async {
    final flow = CreateInviteFlow(
        createInviteService: CreateInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: _startNewConnection,
        onCanceled: _closeCreateInviteFlow);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  Future<void> _startNewConnection() async {
    createConnectionService.setOnConnectedListener(() {
      navigator.replaceScreen(
        ClipboardScreen(
          viewModel: ClipboardScreenViewModel(
              closeConnectionUseCase: createConnectionService,
              dataTransceiver: createConnectionService,
              navigator: navigator,
              clipboardService: clipboardService),
        ),
      );
    });
    createConnectionService.startNewConnection();
  }

  Future<void> _closeCreateInviteFlow() async {
    navigator.popScreen();
  }

  void _onJoinWithQrCodeButtonClicked() {
    final flow = JoinInviteFlow(
        viewType: JoinInviteViewType.camera,
        onInviteAccepted: _onInviteAccepted,
        joinInviteService: JoinInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: _joinNewConnection,
        onCanceled: _closeJoinInviteFlow);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  Future<void> _closeJoinInviteFlow() async {
    navigator.popScreen();
  }

  void _onInviteAccepted(Invite invite) {
    _invite = invite;
  }

  Future<void> _joinNewConnection() async {
    joinConnectionService.setOnConnectedListener(() {
      navigator.replaceScreen(ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            clipboardService: clipboardService,
            closeConnectionUseCase: joinConnectionService,
            dataTransceiver: joinConnectionService,
            navigator: navigator),
      ));
    });

    try {
      //todo: add loading screen
      // _updateState('', loading: true);
      await joinConnectionService.joinConnection(_invite!.creator);
    } catch (e) {
      // _updateState('Unable to connect');
    }
  }

  void _onJoinConnectionButtonClicked() {
    final flow = JoinInviteFlow(
        viewType: JoinInviteViewType.code,
        onInviteAccepted: _onInviteAccepted,
        joinInviteService: JoinInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: _joinNewConnection,
        onCanceled: _closeJoinInviteFlow);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }
}
