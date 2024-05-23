import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/create/create_flow.dart';
import 'package:p2p_copy_paste/join/join_flow.dart';
import 'package:p2p_copy_paste/screens/vertical_menu.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/system_manager.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

enum _StateId {
  overview,
  getStarted,
  loading,
  create,
  join,
}

class MainFlow extends Flow<_StateId> {
  final INavigator navigator;
  late StreamSubscription<LoginState> loginStateSubscription;
  final ISystemManager systemManager;
  JoinViewType _joinViewType = JoinViewType.camera;

  WeakReference<IAuthenticationService>? _authenticationService;

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
        state: FlowState(name: 'create', onEntry: _onEntryCreateState),
        stateId: _StateId.create);
    addState(
        state: FlowState(name: 'join', onEntry: _onEntryJoinState),
        stateId: _StateId.join);
    addState(
        state: FlowState(name: 'get started', onEntry: _onEntryGetStartedState),
        stateId: _StateId.getStarted);

    setInitialState(_StateId.loading);
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
    final flow = CreateFlow(
        createFeature: systemManager,
        clipboardFeature: systemManager,
        navigator: navigator,
        onCompleted: _closeScreenAndReturnToOverview,
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  void _onEntryJoinState() {
    final flow = JoinFlow(
        viewType: _joinViewType,
        joinFeature: systemManager,
        clipboardFeature: systemManager,
        navigator: navigator,
        onCompleted: _closeScreenAndReturnToOverview,
        onCanceled: _closeScreenAndReturnToOverview);

    navigator.pushScreen(FlowScreen(viewModel: FlowScreenViewModel(flow)));
  }

  Future<void> _closeScreenAndReturnToOverview() async {
    navigator.popScreen();
    setState(_StateId.overview);
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
            }, this));
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
    }, this));
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
