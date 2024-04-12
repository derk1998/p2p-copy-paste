import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/widgets/home.dart';
import 'package:p2p_copy_paste/widgets/login.dart';
import 'package:p2p_copy_paste/view_models/startup.dart';

class StartupScreen extends ScreenView<StartupScreenViewModel> {
  const StartupScreen({super.key, required super.viewModel});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState
    extends ScreenViewState<StartupScreen, StartupScreenViewModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StartupScreenState>(
      stream: viewModel.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(viewModel.title),
          ),
          body: !snapshot.hasData || snapshot.data!.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : snapshot.data!.loginState == LoginState.loggedIn
                  ? HomeScreen(viewModel: viewModel.homeScreenViewModel)
                  : LoginScreen(viewModel: viewModel.loginScreenViewModel),
        );
      },
    );
  }
}
