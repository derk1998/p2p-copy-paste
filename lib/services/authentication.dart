import 'package:flutter_fd/flutter_fd.dart';

enum LoginState { loggedIn, loggedOut, loggingIn }

abstract class IAuthenticationService extends Disposable {
  Future<void> signInAnonymously();
  String getUserId();

  Stream<LoginState> stream();
}
