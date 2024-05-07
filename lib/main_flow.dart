import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:p2p_copy_paste/create/create_flow.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/join/join_flow.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/repositories/connection_info_repository.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/screens/flow.dart';
import 'package:p2p_copy_paste/screens/vertical_menu.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/join/services/join_connection.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/view_models/flow.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

enum _StateId {
  overview,
  getStarted,
  privacyPolicy,
  loading,
  create,
  joinWithQrCode,
  joinWithCode,
  clipboard,
  dialog,
}

class MainFlow extends Flow<FlowState, _StateId> {
  final IAuthenticationService authenticationService;
  final INavigator navigator;
  final IInviteRepository inviteRepository;
  final IConnectionInfoRepository connectionInfoRepository;
  final IFileService fileService;
  final IClipboardService clipboardService;
  JoinConnectionService? joinConnectionService;
  late StreamSubscription<LoginState> loginStateSubscription;
  TransceiveDataUseCase? transceiveDataUseCase;

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
        state: FlowState(name: 'create', onEntry: _onEntryCreateState),
        stateId: _StateId.create);
    addState(
        state: FlowState(
            name: 'join with qr code', onEntry: _onEntryJoinWithQrCodeState),
        stateId: _StateId.joinWithQrCode);
    addState(
        state: FlowState(
            name: 'join with code', onEntry: _onEntryJoinWithCodeState),
        stateId: _StateId.joinWithCode);
    addState(
        state: FlowState(
            name: 'privacy policy',
            onEntry: _onEntryPrivacyPolicyState,
            onExit: _onExitPrivacyPolicyState),
        stateId: _StateId.privacyPolicy);
    addState(
        state: FlowState(name: 'get started', onEntry: _onEntryGetStartedState),
        stateId: _StateId.getStarted);
    addState(
        state: FlowState(name: 'clipboard', onEntry: _onEntryClipboardState),
        stateId: _StateId.clipboard);
    addState(
        state: FlowState(name: 'dialog', onEntry: _onEntryDialogState),
        stateId: _StateId.dialog);

    setInitialState(_StateId.loading);
  }

  @override
  void onPopInvoked() {
    if (isCurrentState(_StateId.clipboard)) {
      setState(_StateId.dialog);
    }
  }

  void _onEntryOverviewState() {
    final buttonViewModelList = [
      ButtonViewModel(
          title: 'Create an invite',
          onPressed: () {
            setState(_StateId.create);
          }),
      if (kDebugMode)
        ButtonViewModel(
            title: 'I have a code',
            onPressed: () {
              setState(_StateId.joinWithCode);
            }),
      if (!kIsWeb)
        ButtonViewModel(
            title: 'I have a QR code',
            onPressed: () {
              setState(_StateId.joinWithQrCode);
            },
            icon: material.Icons.qr_code)
    ];

    final view = VerticalMenuScreen(
        viewModel: MenuScreenViewModel(
      title: 'P2P Copy Paste',
      description:
          'Start copying and pasting between devices. Download the app or go to https://cp.xdatwork.com on your other device.',
      buttonViewModelList: buttonViewModelList,
    ));

    viewChangeSubject.add(view);
  }

  void _onEntryCreateState() {
    final flow = CreateFlow(
        onConnected: _onConnected,
        createInviteService: CreateInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        createConnectionService: CreateConnectionService(
            connectionInfoRepository: connectionInfoRepository),
        onCompleted: _closeScreenAndOpenClipboard,
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  void _onEntryJoinWithQrCodeState() {
    final flow = JoinFlow(
        viewType: JoinViewType.camera,
        onConnected: _onConnected,
        joinConnectionService: JoinConnectionService(
            connectionInfoRepository: connectionInfoRepository),
        joinInviteService: JoinInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: _closeScreenAndOpenClipboard,
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  Future<void> _closeScreenAndReturnToOverview() async {
    navigator.popScreen();
    setState(_StateId.overview);
  }

  Future<void> _closeScreenAndOpenClipboard() async {
    navigator.popScreen();
    setState(_StateId.clipboard);
  }

  void _onEntryJoinWithCodeState() {
    final flow = JoinFlow(
        viewType: JoinViewType.code,
        onConnected: _onConnected,
        joinConnectionService: JoinConnectionService(
            connectionInfoRepository: connectionInfoRepository),
        joinInviteService: JoinInviteService(
            authenticationService: authenticationService,
            inviteRepository: inviteRepository),
        onCompleted: _closeScreenAndOpenClipboard,
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
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
      ButtonViewModel(
          title: 'Get started',
          onPressed: () {
            setState(_StateId.privacyPolicy);
          },
          icon: material.Icons.arrow_forward)
    ];

    final view = VerticalMenuScreen(
        viewModel: MenuScreenViewModel(
      title: 'P2P Copy Paste',
      description:
          'You are one step away from easy copying and pasting between devices.',
      buttonViewModelList: buttonViewModelList,
    ));

    viewChangeSubject.add(view);
  }

  void _onConnected(TransceiveDataUseCase usecase) {
    transceiveDataUseCase = usecase;
  }

  void _onEntryClipboardState() {
    transceiveDataUseCase!.setOnConnectionClosedListener(() {
      setState(_StateId.overview);
    });

    final view = ClipboardScreen(
      viewModel: ClipboardScreenViewModel(
          dataTransceiver: transceiveDataUseCase!,
          clipboardService: clipboardService),
    );

    viewChangeSubject.add(view);
  }

  void _onEntryDialogState() {
    navigator.pushDialog(
      CancelConfirmDialog(
        viewModel: CancelConfirmViewModel(
          title: 'Are you sure?',
          description: 'The connection will be lost',
          onCancelButtonPressed: () {
            navigator.popScreen();
          },
          onConfirmButtonPressed: () {
            transceiveDataUseCase!.dispose();
            navigator.popScreen();
          },
        ),
      ),
    );
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
