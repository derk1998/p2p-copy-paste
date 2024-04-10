import 'dart:core';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

class LoginScreenViewModel {
  LoginScreenViewModel() {
    loginButtonViewModel =
        ButtonViewModel(title: 'Get started', onPressed: _onLoginButtonClicked);
  }

  late ButtonViewModel loginButtonViewModel;

  void _onLoginButtonClicked() async {
    final privacyPolicyText =
        await rootBundle.loadString('assets/text/privacy-policy.md');
    _showPrivacyPolicyDialog(privacyPolicyText);
  }

  void _showPrivacyPolicyDialog(String privacyPolicyText) {
    GetIt.I.get<INavigator>().pushDialog(
          CancelConfirmDialog(
            viewModel: CancelConfirmViewModel(
                isContentMarkdown: true,
                description: privacyPolicyText,
                title: 'Read the following',
                cancelName: 'Disagree',
                confirmName: 'Agree',
                onCancelButtonPressed: () {
                  GetIt.I.get<INavigator>().popScreen();
                },
                onConfirmButtonPressed: () {
                  GetIt.I.get<INavigator>().popScreen();
                  GetIt.I.get<IAuthenticationService>().signInAnonymously();
                }),
          ),
        );
  }
}

final loginScreenViewModelProvider = Provider<LoginScreenViewModel>((ref) {
  return LoginScreenViewModel();
});
