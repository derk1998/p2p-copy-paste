import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/services/login.dart';
import 'package:test_webrtc/view_models/button.dart';

class LoginScreenViewModel {
  LoginScreenViewModel({required this.ref}) {
    loginButtonViewModel =
        ButtonViewModel(title: 'Get started', onPressed: _onLoginButtonClicked);
  }

  final Ref ref;
  late ButtonViewModel loginButtonViewModel;

  void _onLoginButtonClicked() async {
    ref.read(loginServiceProvider).login();
  }
}

final loginScreenViewModelProvider = Provider<LoginScreenViewModel>((ref) {
  return LoginScreenViewModel(ref: ref);
});
