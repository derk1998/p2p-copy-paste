import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/view_models/login.dart';
import 'package:p2p_copy_paste/widgets/button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(loginScreenViewModelProvider);

    return Center(child: Button(viewModel: viewModel.loginButtonViewModel));
  }
}
