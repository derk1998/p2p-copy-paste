import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/create_invite/screens/create_invite.dart';
import 'package:p2p_copy_paste/screens/join_connection.dart';
import 'package:p2p_copy_paste/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/services/file.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/view_models/home.dart';
import 'package:p2p_copy_paste/view_models/login.dart';
import 'package:p2p_copy_paste/view_models/startup.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

import 'startup_screen_test.mocks.dart';

@GenerateMocks([
  INavigator,
  IAuthenticationService,
  IFileService,
  IClipboardService,
  ICreateConnectionService,
  ICreateInviteService,
  IJoinConnectionService,
  IJoinInviteService
])
void main() {
  late StartupScreenViewModel viewModel;
  final mockNavigator = MockINavigator();
  late MockIAuthenticationService mockAuthenticationService;
  late MockIFileService mockFileService;

  GetIt.I.registerSingleton<INavigator>(mockNavigator);
  GetIt.I.registerSingleton<IClipboardService>(MockIClipboardService());
  GetIt.I.registerSingleton<ICreateInviteService>(MockICreateInviteService());
  GetIt.I.registerSingleton<ICreateConnectionService>(
      MockICreateConnectionService());
  GetIt.I
      .registerSingleton<IJoinConnectionService>(MockIJoinConnectionService());
  GetIt.I.registerSingleton<IJoinInviteService>(MockIJoinInviteService());

  setUp(() {
    mockAuthenticationService = MockIAuthenticationService();
    mockFileService = MockIFileService();

    viewModel = StartupScreenViewModel(
        authenticationService: mockAuthenticationService,
        homeScreenViewModel: HomeScreenViewModel(GetIt.I),
        loginScreenViewModel: LoginScreenViewModel(
            authenticationService: mockAuthenticationService,
            fileService: mockFileService,
            navigator: mockNavigator));

    viewModel.init();
  });

  group('Startup screen', () {
    test('Verify initial state is loading and logged out', () async {
      final state = await viewModel.state.first;

      expect(state.loading, isTrue);
      expect(state.loginState, LoginState.loggedOut);
    });

    test('Verify if login state from auth service is propagated to view',
        () async {
      final listener = verify(mockAuthenticationService
              .setOnLoginStateChangedListener(captureAny))
          .captured[0];

      listener(LoginState.loggedIn);
      var state = await viewModel.state.first;
      expect(state.loginState, LoginState.loggedIn);

      listener(LoginState.loggedOut);
      state = await viewModel.state.first;
      expect(state.loginState, LoginState.loggedOut);

      listener(LoginState.loggingIn);
      state = await viewModel.state.first;
      expect(state.loginState, LoginState.loggingIn);
    });

    test('Verify if screen is loading when logging in', () async {
      final listener = verify(mockAuthenticationService
              .setOnLoginStateChangedListener(captureAny))
          .captured[0];

      listener(LoginState.loggingIn);
      final state = await viewModel.state.first;
      expect(state.loading, true);
    });

    test(
        'Verify if screen is not loading when logged out after reply from auth service',
        () async {
      final listener = verify(mockAuthenticationService
              .setOnLoginStateChangedListener(captureAny))
          .captured[0];

      listener(LoginState.loggedOut);
      final state = await viewModel.state.first;
      expect(state.loading, false);
    });
  });

  group('Login screen', () {
    test(
        'Verify if privacy policy dialog is shown when get started button is pressed',
        () async {
      when(mockFileService.loadFile(any))
          .thenAnswer((realInvocation) => Future(() => 'file'));
      viewModel.loginScreenViewModel.loginButtonViewModel.onPressed();

      await untilCalled(mockNavigator.pushDialog(any));

      expect(verify(mockNavigator.pushDialog(captureAny)).captured[0],
          isA<CancelConfirmDialog>());
    });

    test(
        'Verify if privacy policy is loaded when get started button is pressed',
        () async {
      when(mockFileService.loadFile(any))
          .thenAnswer((realInvocation) => Future(() => 'file'));
      viewModel.loginScreenViewModel.loginButtonViewModel.onPressed();

      await untilCalled(
          mockFileService.loadFile('assets/text/privacy-policy.md'));
    });

    test(
        'Verify if privacy policy dialog is closed when cancel button is pressed',
        () async {
      when(mockFileService.loadFile(any))
          .thenAnswer((realInvocation) => Future(() => 'file'));
      viewModel.loginScreenViewModel.loginButtonViewModel.onPressed();

      await untilCalled(mockNavigator.pushDialog(any));

      final CancelConfirmDialog privacyPolicyDialog =
          verify(mockNavigator.pushDialog(captureAny)).captured[0];

      privacyPolicyDialog.viewModel.cancelButtonViewModel.onPressed();

      verify(mockNavigator.popScreen()).called(1);
    });

    test(
        'Verify if privacy policy dialog is closed when confirm button is pressed',
        () async {
      when(mockFileService.loadFile(any))
          .thenAnswer((realInvocation) => Future(() => 'file'));
      viewModel.loginScreenViewModel.loginButtonViewModel.onPressed();

      await untilCalled(mockNavigator.pushDialog(any));

      final CancelConfirmDialog privacyPolicyDialog =
          verify(mockNavigator.pushDialog(captureAny)).captured[0];

      privacyPolicyDialog.viewModel.confirmButtonViewModel.onPressed();

      verify(mockNavigator.popScreen()).called(1);
    });

    test('Verify if signing in when privacy policy confirm button is pressed',
        () async* {
      when(mockFileService.loadFile(any))
          .thenAnswer((realInvocation) => Future(() => 'file'));

      viewModel.loginScreenViewModel.loginButtonViewModel.onPressed();

      await untilCalled(mockNavigator.pushDialog(any));

      final CancelConfirmDialog privacyPolicyDialog =
          verify(mockNavigator.pushDialog(captureAny)).captured[0];

      privacyPolicyDialog.viewModel.confirmButtonViewModel.onPressed();
      verify(mockAuthenticationService.signInAnonymously()).called(1);
    });

    test(
        'Verify if not signing in when privacy policy cancel button is pressed',
        () async {
      when(mockFileService.loadFile(any))
          .thenAnswer((realInvocation) => Future(() => 'file'));
      viewModel.loginScreenViewModel.loginButtonViewModel.onPressed();

      await untilCalled(mockNavigator.pushDialog(any));

      final CancelConfirmDialog privacyPolicyDialog =
          verify(mockNavigator.pushDialog(captureAny)).captured[0];

      privacyPolicyDialog.viewModel.cancelButtonViewModel.onPressed();

      verifyNever(mockAuthenticationService.signInAnonymously());
    });

    group('Home screen', () {
      test(
          'Verify if create invite screen is displayed when create invite button is pressed',
          () async {
        viewModel.homeScreenViewModel.startNewConnectionButtonViewModel
            .onPressed();

        expect(verify(mockNavigator.pushScreen(captureAny)).captured[0],
            isA<CreateInviteScreen>());
      });

      if (kDebugMode) {
        test(
            'Verify if scan qr code screen is displayed when scan qr code button is pressed',
            () async {
          viewModel.homeScreenViewModel.joinWithQrCodeButtonViewModel!
              .onPressed();

          expect(verify(mockNavigator.pushScreen(captureAny)).captured[0],
              isA<ScanQRCodeScreen>());
        });
      }

      test(
          'Verify if join connection screen is displayed when join connection button is pressed',
          () async {
        viewModel.homeScreenViewModel.joinConnectionButtonViewModel!
            .onPressed();

        expect(verify(mockNavigator.pushScreen(captureAny)).captured[0],
            isA<JoinConnectionScreen>());
      });
    });
  });
}
