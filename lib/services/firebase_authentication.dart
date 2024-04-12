import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:p2p_copy_paste/services/authentication.dart';

class FirebaseAuthenticationService extends IAuthenticationService {
  StreamSubscription<User?>? _subscription;
  void Function(LoginState)? _onLoginStateChangedListener;

  @override
  Future<void> signInAnonymously() async {
    _onLoginStateChangedListener?.call(LoginState.loggingIn);
    await FirebaseAuth.instance.signInAnonymously();
  }

  @override
  String getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void setOnLoginStateChangedListener(
      void Function(LoginState p1) onLoginStateChangedListener) {
    _subscription?.cancel();
    _onLoginStateChangedListener = onLoginStateChangedListener;
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _onLoginStateChangedListener
          ?.call(user == null ? LoginState.loggedOut : LoginState.loggedIn);
    });
  }
}
