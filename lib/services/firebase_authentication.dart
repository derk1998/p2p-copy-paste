import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseAuthenticationService extends IAuthenticationService {
  StreamSubscription<User?>? _subscription;

  late BehaviorSubject<LoginState> loginStateSubject;
  FirebaseAuthenticationService() {
    loginStateSubject = BehaviorSubject<LoginState>(
      onListen: () {
        _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
          loginStateSubject
              .add(user == null ? LoginState.loggedOut : LoginState.loggedIn);
        });
      },
      onCancel: () {
        _subscription?.cancel();
      },
    );
  }

  @override
  Future<void> signInAnonymously() async {
    loginStateSubject.add(LoginState.loggingIn);
    await FirebaseAuth.instance.signInAnonymously();
  }

  @override
  String getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Stream<LoginState> stream() {
    return loginStateSubject;
  }

  @override
  void dispose() {
    loginStateSubject.close();
  }
}
