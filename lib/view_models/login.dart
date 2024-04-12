import 'dart:core';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

class LoginScreenViewModel {
  LoginScreenViewModel(
      {required this.navigator,
      required this.authenticationService,
      required this.fileService}) {
    loginButtonViewModel =
        ButtonViewModel(title: 'Get started', onPressed: _onLoginButtonClicked);
  }

  late ButtonViewModel loginButtonViewModel;
  final INavigator navigator;
  final IAuthenticationService authenticationService;
  final IFileService fileService;

  void _onLoginButtonClicked() async {
    final privacyPolicyText =
        await fileService.loadFile('assets/text/privacy-policy.md');
    _showPrivacyPolicyDialog(privacyPolicyText);
  }

  void _showPrivacyPolicyDialog(String privacyPolicyText) {
    navigator.pushDialog(
      CancelConfirmDialog(
        viewModel: CancelConfirmViewModel(
            isContentMarkdown: true,
            description: privacyPolicyText,
            title: 'Read the following',
            cancelName: 'Disagree',
            confirmName: 'Agree',
            onCancelButtonPressed: () {
              navigator.popScreen();
            },
            onConfirmButtonPressed: () {
              authenticationService.signInAnonymously();
              navigator.popScreen();
            }),
      ),
    );
  }
}
