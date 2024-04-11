import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/widgets/home.dart';
import 'package:p2p_copy_paste/widgets/login.dart';
import 'package:p2p_copy_paste/view_models/startup.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key, required this.viewModel});

  final StartupScreenViewModel viewModel;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    widget.viewModel.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StartupScreenState>(
      stream: widget.viewModel.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.viewModel.title),
          ),
          body: !snapshot.hasData || snapshot.data!.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : snapshot.data!.loginState == LoginState.loggedIn
                  ? HomeScreen(viewModel: widget.viewModel.homeScreenViewModel)
                  : LoginScreen(
                      viewModel: widget.viewModel.loginScreenViewModel),
        );
      },
    );
  }
}
