import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/view_models/login.dart';
import 'package:p2p_copy_paste/widgets/button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginScreenViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(child: Button(viewModel: viewModel.loginButtonViewModel));
  }
}
