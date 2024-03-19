import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginService {
  Future<void> login() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  String getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }
}

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
LoginService? _loginService;

final loginServiceProvider = Provider<LoginService>((ref) {
  _loginService ??= LoginService();
  return _loginService!;
});
