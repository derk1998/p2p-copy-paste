enum LoginState { loggedIn, loggedOut, loggingIn }

abstract class IAuthenticationService {
  Future<void> signInAnonymously();
  String getUserId();
  void setOnLoginStateChangedListener(
      void Function(LoginState) onLoginStateChangedListener);
}
