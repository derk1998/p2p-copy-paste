import 'dart:async';

import 'package:fd_dart/fd_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/create/create_flow.dart';
import 'package:p2p_copy_paste/join/join_flow.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/screens/vertical_menu.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/system_manager.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

enum _StateId {
  overview,
  getStarted,
  loading,
  create,
  join,
  clipboard,
}

class MainFlow extends Flow<FlowState, _StateId> {
  final INavigator navigator;
  late StreamSubscription<LoginState> loginStateSubscription;
  final ISystemManager systemManager;
  JoinViewType _joinViewType = JoinViewType.camera;

  WeakReference<IAuthenticationService>? _authenticationService;
  WeakReference<IConnectionService>? _connectionService;

  MainFlow(
      {required this.navigator,
      required this.systemManager,
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
            name: 'create',
            onEntry: _onEntryCreateState,
            onExit: _onExitCreateState),
        stateId: _StateId.create);
    addState(
        state: FlowState(
            name: 'join', onEntry: _onEntryJoinState, onExit: _onExitJoinState),
        stateId: _StateId.join);
    addState(
        state: FlowState(name: 'get started', onEntry: _onEntryGetStartedState),
        stateId: _StateId.getStarted);
    addState(
        state: FlowState(
            name: 'clipboard',
            onEntry: _onEntryClipboardState,
            onExit: _onExitClipboardState),
        stateId: _StateId.clipboard);

    setInitialState(_StateId.loading);
  }

  @override
  void onPopInvoked() {
    if (isCurrentState(_StateId.clipboard)) {
      navigator.pushDialog(
        CancelConfirmDialog(
          viewModel: CancelConfirmViewModel(
            title: 'Are you sure?',
            description: 'The connection will be lost',
            onCancelButtonPressed: () {
              navigator.popScreen();
            },
            onConfirmButtonPressed: () {
              navigator.popScreen();
              _connectionService!.target!.close();
            },
          ),
        ),
      );
    }
  }

  void _onEntryOverviewState() {
    systemManager.removeCreateConnectionServiceListener(getContext());
    systemManager.removeJoinConnectionServiceListener(getContext());

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
              _joinViewType = JoinViewType.code;
              setState(_StateId.join);
            }),
      if (!kIsWeb)
        ButtonViewModel(
            title: 'I have a QR code',
            onPressed: () {
              _joinViewType = JoinViewType.camera;
              setState(_StateId.join);
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

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onEntryCreateState() {
    loading();

    systemManager
        .addCreateConnectionServiceListener(Listener((createConnectionService) {
      _connectionService = createConnectionService;

      systemManager
          .addCreateInviteServiceListener(Listener((createInviteService) {
        final flow = CreateFlow(
            createConnectionService: createConnectionService,
            createInviteService: createInviteService,
            onCompleted: _closeScreenAndOpenClipboard,
            onCanceled: _closeScreenAndReturnToOverview);

        navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
      }, getContext()));
    }, getContext()));
  }

  void _onExitCreateState() {
    systemManager.removeCreateInviteServiceListener(getContext());
  }

  void _onEntryJoinState() {
    loading();

    systemManager
        .addJoinConnectionServiceListener(Listener((joinConnectionService) {
      _connectionService = joinConnectionService;

      systemManager.addJoinInviteServiceListener(Listener((joinInviteService) {
        final flow = JoinFlow(
            viewType: _joinViewType,
            onCompleted: _closeScreenAndOpenClipboard,
            onCanceled: _closeScreenAndReturnToOverview,
            joinConnectionService: joinConnectionService,
            joinInviteService: joinInviteService);

        navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
      }, getContext()));
    }, getContext()));
  }

  void _onExitJoinState() {
    systemManager.removeJoinInviteServiceListener(getContext());
  }

  Future<void> _closeScreenAndReturnToOverview() async {
    navigator.popScreen();
    setState(_StateId.overview);
  }

  Future<void> _closeScreenAndOpenClipboard() async {
    navigator.popScreen();
    setState(_StateId.clipboard);
  }

  void _onEntryLoadingState() {
    loading();
  }

  void _onEntryGetStartedState() {
    final buttonViewModelList = [
      ButtonViewModel(
          title: 'Get started',
          onPressed: () {
            systemManager.addFileServiceListener(Listener((service) {
              service.target!
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
                        navigator.popScreen();
                        systemManager.removeFileServiceListener(getContext());
                      },
                      onConfirmButtonPressed: () {
                        navigator.popScreen();
                        _authenticationService!.target!.signInAnonymously();
                        systemManager.removeFileServiceListener(getContext());
                      }),
                ));
              });
            }, getContext()));
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

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onEntryClipboardState() {
    loading();
    _connectionService!.target!.setOnDisconnectedListener(() {
      setState(_StateId.overview);
    });

    systemManager.addClipboardServiceListener(Listener((service) {
      final view = ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            connectionService: _connectionService!, clipboardService: service),
      );

      viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
    }, getContext()));
  }

  void _onExitClipboardState() {
    systemManager.removeClipboardServiceListener(getContext());
    systemManager.removeCreateConnectionServiceListener(getContext());
    systemManager.removeJoinConnectionServiceListener(getContext());
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

    systemManager.addAuthenticationServiceListener(Listener((service) {
      _authenticationService = service;
      loginStateSubscription =
          service.target!.stream().listen(_onLoginStateChanged);
    }, getContext()));
  }

  @override
  void dispose() {
    loginStateSubscription.cancel();
    super.dispose();
  }

  @override
  String name() {
    return 'Main flow';
  }
}
