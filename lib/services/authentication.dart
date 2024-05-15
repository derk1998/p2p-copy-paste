import 'package:fd_dart/fd_dart.dart';

enum LoginState { loggedIn, loggedOut, loggingIn }

abstract class IAuthenticationService extends Disposable {
  Future<void> signInAnonymously();
  String getUserId();

  Stream<LoginState> stream();
}
