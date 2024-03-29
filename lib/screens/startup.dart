import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/screens/home.dart';
import 'package:test_webrtc/screens/login.dart';
import 'package:test_webrtc/services/login.dart';
import 'package:test_webrtc/view_models/startup.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LoginState?> state =
        ref.watch(startupScreenViewModelProvider);

    if (state.isLoading || state.value == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.value! == LoginState.loggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
