import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoginState { loggedIn, loggedOut, loggingIn }

class LoginService {
  StreamSubscription<User?>? _subscription;
  void Function(LoginState)? _onLoginStateChangedListener;

  Future<void> login() async {
    _onLoginStateChangedListener?.call(LoginState.loggingIn);
    FirebaseAuth.instance.signInAnonymously();
  }

  String getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  void setOnLoginStateChangedListener(
      void Function(LoginState) onLoginStateChangedListener) {
    _subscription?.cancel();
    _onLoginStateChangedListener = onLoginStateChangedListener;
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _onLoginStateChangedListener
          ?.call(user == null ? LoginState.loggedOut : LoginState.loggedIn);
    });
  }
}

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
LoginService? _loginService;

final loginServiceProvider = Provider<LoginService>((ref) {
  _loginService ??= LoginService();
  return _loginService!;
});
