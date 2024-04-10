import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/view_models/home.dart';
import 'package:p2p_copy_paste/view_models/login.dart';
import 'package:p2p_copy_paste/widgets/home.dart';
import 'package:p2p_copy_paste/widgets/login.dart';
import 'package:p2p_copy_paste/view_models/startup.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LoginState?> state =
        ref.watch(startupScreenViewModelProvider);

    final viewModel = ref.watch(startupScreenViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
      ),
      body: state.isLoading || state.value == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.value! == LoginState.loggedIn
              ? HomeScreen(viewModel: ref.read(homeScreenViewModelProvider))
              : LoginScreen(viewModel: ref.read(loginScreenViewModelProvider)),
    );
  }
}
