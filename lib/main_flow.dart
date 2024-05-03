import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:p2p_copy_paste/create_invite/create_invite_flow.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/join_invite/join_invite_flow.dart';
import 'package:p2p_copy_paste/join_invite/join_invite_service.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/screens/flow.dart';
import 'package:p2p_copy_paste/screens/menu.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/view_models/flow.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

enum _StateId {
  overview,
  getStarted,
  loading,
  createInvite,
  createConnection,
  createClipboard,
  joinInviteWithQrCode,
  joinInviteWithCode,
  joinConnection,
  privacyPolicy
}

class MainFlow extends Flow<FlowState, _StateId> {
  final IAuthenticationService authenticationService;
  final INavigator navigator;
  final IInviteRepository inviteRepository;
  final IConnectionInfoRepository connectionInfoRepository;
  final IFileService fileService;
  final IClipboardService clipboardService;
  CreateConnectionService? createConnectionService;
  JoinConnectionService? joinConnectionService;
  Invite? _invite;
  late StreamSubscription<LoginState> loginStateSubscription;

  MainFlow(
      {required this.authenticationService,
      required this.navigator,
      required this.inviteRepository,
      required this.connectionInfoRepository,
      required this.fileService,
      required this.clipboardService,
      super.onCompleted,
      super.onCanceled}) {
    addState(
        state: FlowState(name: 'loading', onEntry: _onEntryLoadingState),
        stateId: _StateId.loading);
    addState(
        state: FlowState(name: 'overview', onEntry: _onEntryOverviewState),
        stateId: _StateId.overview);
    addState(
        state: FlowState(
            name: 'create invite', onEntry: _onEntryCreateInviteState),
        stateId: _StateId.createInvite);

    addState(
        state: FlowState(
            name: 'create connection', onEntry: _onEntryCreateConnectionState),
        stateId: _StateId.createConnection);
    addState(
        state: FlowState(
            name: 'create clipboard',
            onEntry: _onEntryCreateClipboardState,
            onExit: _onExitCreateClipboardState),
        stateId: _StateId.createClipboard);
    addState(
        state: FlowState(
            name: 'join invite with qr code',
            onEntry: _onEntryJoinInviteWithQrCodeState),
        stateId: _StateId.joinInviteWithQrCode);
    addState(
        state: FlowState(
            name: 'join invite with code',
            onEntry: _onEntryJoinInviteWithCodeState),
        stateId: _StateId.joinInviteWithCode);
    addState(
        state: FlowState(
            name: 'join connection', onEntry: _onEntryJoinConnectionState),
        stateId: _StateId.joinConnection);
    addState(
        state: FlowState(
            name: 'privacy policy',
            onEntry: _onEntryPrivacyPolicyState,
            onExit: _onExitPrivacyPolicyState),
        stateId: _StateId.privacyPolicy);

    addState(
        state: FlowState(name: 'get started', onEntry: _onEntryGetStartedState),
        stateId: _StateId.getStarted);

    setInitialState(_StateId.loading);
  }

  void _onEntryOverviewState() {
    final buttonViewModelList = [
      IconButtonViewModel(
          title: 'Create an invite',
          onPressed: () {
            setState(_StateId.createInvite);
          },
          icon: material.Icons.add),
      if (kDebugMode)
        IconButtonViewModel(
            title: 'I have a code',
            onPressed: () {
              setState(_StateId.joinInviteWithCode);
            },
            icon: material.Icons.numbers),
      if (!kIsWeb)
        IconButtonViewModel(
            title: 'I have a QR code',
            onPressed: () {
              setState(_StateId.joinInviteWithCode);
            },
            icon: material.Icons.qr_code)
    ];

    final view = MenuScreen(
        viewModel: MenuScreenViewModel(
      title: 'P2P Copy Paste',
      description:
          'Start copying and pasting between devices. Download the app or go to https://cp.xdatwork.com on your other device.',
      buttonViewModelList: buttonViewModelList,
    ));

    viewChangeSubject.add(view);
  }

  void _onEntryCreateInviteState() {
    final flow = CreateInviteFlow(
        createInviteService: CreateInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: () async {
          setState(_StateId.createConnection);
        },
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  void _onEntryCreateConnectionState() {
    createConnectionService = CreateConnectionService(
        connectionInfoRepository: connectionInfoRepository,
        authenticationService: authenticationService);

    createConnectionService!.setOnConnectedListener(() {
      setState(_StateId.createClipboard);
    });

    createConnectionService!.startNewConnection();
  }

  void _onEntryCreateClipboardState() {
    navigator.replaceScreen(
      ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            closeConnectionUseCase: createConnectionService!,
            dataTransceiver: createConnectionService!,
            navigator: navigator,
            clipboardService: clipboardService),
      ),
    );
  }

  void _onExitCreateClipboardState() {
    createConnectionService?.dispose();
  }

  void _onEntryJoinInviteWithQrCodeState() {
    final flow = JoinInviteFlow(
        viewType: JoinInviteViewType.camera,
        onInviteAccepted: _onInviteAccepted,
        joinInviteService: JoinInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: _joinNewConnection,
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  void _onInviteAccepted(Invite invite) {
    _invite = invite;
  }

  Future<void> _joinNewConnection() async {
    setState(_StateId.joinConnection);
  }

  Future<void> _closeScreenAndReturnToOverview() async {
    navigator.popScreen();
    setState(_StateId.overview);
  }

  void _onEntryJoinInviteWithCodeState() {
    final flow = JoinInviteFlow(
        viewType: JoinInviteViewType.code,
        onInviteAccepted: _onInviteAccepted,
        joinInviteService: JoinInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: _joinNewConnection,
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  void _onEntryJoinConnectionState() {
    joinConnectionService = JoinConnectionService(
        connectionInfoRepository: connectionInfoRepository);

    joinConnectionService!.setOnConnectedListener(() {
      navigator.replaceScreen(ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            clipboardService: clipboardService,
            closeConnectionUseCase: joinConnectionService!,
            dataTransceiver: joinConnectionService!,
            navigator: navigator),
      ));
    });

    //todo: the state needs to be captured so the state can be changed when connection fails
    joinConnectionService?.joinConnection(_invite!.creator);
  }

  void _onEntryPrivacyPolicyState() {
    fileService
        .loadFile('assets/text/privacy-policy.md')
        .then((privacyPolicyText) {
      navigator.pushDialog(CancelConfirmDialog(
        viewModel: CancelConfirmViewModel(
            isContentMarkdown: true,
            description: privacyPolicyText,
            title: 'Read the following',
            cancelName: 'Disagree',
            confirmName: 'Agree',
            onCancelButtonPressed: () {
              setState(_StateId.getStarted);
            },
            onConfirmButtonPressed: () {
              authenticationService.signInAnonymously();
            }),
      ));
    });
  }

  void _onExitPrivacyPolicyState() {
    navigator.popScreen();
  }

  void _onEntryLoadingState() {
    loading();
  }

  void _onEntryGetStartedState() {
    final buttonViewModelList = [
      IconButtonViewModel(
          title: 'Get started',
          onPressed: () {
            setState(_StateId.privacyPolicy);
          },
          icon: material.Icons.arrow_forward)
    ];

    final view = MenuScreen(
        viewModel: MenuScreenViewModel(
      title: 'P2P Copy Paste',
      description:
          'You are one step away from easy copying and pasting between devices.',
      buttonViewModelList: buttonViewModelList,
    ));

    viewChangeSubject.add(view);
  }

  void _onLoginStateChanged(LoginState loginState) {
    switch (loginState) {
      case LoginState.loggedIn:
        setState(_StateId.overview);
        break;
      case LoginState.loggingIn:
        setState(_StateId.loading);
        break;
      case LoginState.loggedOut:
        setState(_StateId.getStarted);
        break;
    }
  }

  @override
  void init() {
    super.init();
    loginStateSubscription =
        authenticationService.stream().listen(_onLoginStateChanged);
  }

  @override
  void dispose() {
    super.dispose();
    loginStateSubscription.cancel();
    authenticationService.dispose();
  }

  @override
  String name() {
    return 'Main flow';
  }
}
