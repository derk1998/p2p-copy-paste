import 'dart:core';

import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/view_models/home.dart';
import 'package:p2p_copy_paste/view_models/login.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class StartupScreenState {
  StartupScreenState(
      {this.loginState = LoginState.loggedOut, this.loading = true});

  LoginState loginState;
  bool loading;
}

class StartupScreenViewModel extends StatefulScreenViewModel {
  final String title = 'P2P Copy Paste';

  StartupScreenViewModel(
      {required this.authenticationService,
      required this.homeScreenViewModel,
      required this.loginScreenViewModel}) {
    _stateSubject = BehaviorSubject<StartupScreenState>.seeded(
      StartupScreenState(),
      onListen: () {
        authenticationService
            .setOnLoginStateChangedListener(_onLoginStateChanged);
      },
    );
  }

  final IAuthenticationService authenticationService;
  final HomeScreenViewModel homeScreenViewModel;
  final LoginScreenViewModel loginScreenViewModel;
  late BehaviorSubject<StartupScreenState> _stateSubject;

  Stream<StartupScreenState> get state => _stateSubject;

  @override
  void init() {}

  @override
  void dispose() {
    _stateSubject.close();
  }

  void _updateState(LoginState loginState, {bool loading = false}) {
    _stateSubject
        .add(StartupScreenState(loginState: loginState, loading: loading));
  }

  void _onLoginStateChanged(LoginState loginState) {
    if (loginState == LoginState.loggedIn ||
        loginState == LoginState.loggedOut) {
      _updateState(loginState);
    } else {
      _updateState(loginState, loading: true);
    }
  }
}
