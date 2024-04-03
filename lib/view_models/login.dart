import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/services/login.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

class LoginScreenViewModel {
  LoginScreenViewModel({required this.ref, required this.navigator}) {
    loginButtonViewModel =
        ButtonViewModel(title: 'Get started', onPressed: _onLoginButtonClicked);
  }

  final Ref ref;
  late ButtonViewModel loginButtonViewModel;
  final NavigatorState navigator;

  void _onLoginButtonClicked() async {
    final privacyPolicyText =
        await rootBundle.loadString('assets/text/privacy-policy.md');
    _showPrivacyPolicyDialog(privacyPolicyText);
  }

  void _showPrivacyPolicyDialog(String privacyPolicyText) {
    showDialog(
      context: navigator.context,
      builder: (context) => CancelConfirmDialog(
        viewModel: CancelConfirmViewModel(
            isContentMarkdown: true,
            description: privacyPolicyText,
            title: 'Read the following',
            cancelName: 'Disagree',
            confirmName: 'Agree',
            onCancelButtonPressed: () {
              navigator.pop();
            },
            onConfirmButtonPressed: () {
              navigator.pop();
              ref.read(loginServiceProvider).login();
            }),
      ),
    );
  }
}

final loginScreenViewModelProvider =
    ProviderFamily<LoginScreenViewModel, NavigatorState>((ref, navigator) {
  return LoginScreenViewModel(ref: ref, navigator: navigator);
});
