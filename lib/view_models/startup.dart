import 'dart:async';
import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/services/login.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class StartupScreenViewModel extends AutoDisposeAsyncNotifier<LoginState?> {
  final String title = 'P2P Copy Paste';
  late ButtonViewModel loginButtonViewModel;

  void _onLoginStateChanged(LoginState loginState) {
    if (loginState == LoginState.loggedIn ||
        loginState == LoginState.loggedOut) {
      state = AsyncValue.data(loginState);
    } else {
      state = const AsyncLoading();
    }
  }

  @override
  FutureOr<LoginState?> build() {
    state = const AsyncLoading();
    ref
        .read(loginServiceProvider)
        .setOnLoginStateChangedListener(_onLoginStateChanged);
    return null;
  }
}

final startupScreenViewModelProvider =
    AutoDisposeAsyncNotifierProvider<StartupScreenViewModel, LoginState?>(() {
  return StartupScreenViewModel();
});
