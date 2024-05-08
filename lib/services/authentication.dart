import 'package:p2p_copy_paste/disposable.dart';

enum LoginState { loggedIn, loggedOut, loggingIn }

abstract class IAuthenticationService extends Disposable {
  Future<void> signInAnonymously();
  String getUserId();

  Stream<LoginState> stream();
}
