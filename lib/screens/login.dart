import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P2P Copy Paste')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signInAnonymously();
          },
          child: const Text('Get started'),
        ),
      ),
    );
  }
}
