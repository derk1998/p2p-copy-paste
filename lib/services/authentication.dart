enum LoginState { loggedIn, loggedOut, loggingIn }

abstract class IAuthenticationService {
  Future<void> signInAnonymously();
  String getUserId();

  Stream<LoginState> stream();
  void dispose();
}
