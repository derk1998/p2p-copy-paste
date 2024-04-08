import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:p2p_copy_paste/main.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/storage.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

import 'startup_screen_test.mocks.dart';

@GenerateMocks([IStorageService, IAuthenticationService])
void main() {
  late MockIAuthenticationService mockAuthenticationService;

  mockAuthenticationService = MockIAuthenticationService();

  GetIt.instance.registerSingleton<IStorageService>(MockIStorageService());
  getIt.registerSingleton<IAuthenticationService>(mockAuthenticationService);

  testWidgets('Verify if "Get started" is displayed when user is logged out',
      (WidgetTester tester) async {
    await tester.pumpWidget(const P2PCopyPaste());

    verify(mockAuthenticationService.setOnLoginStateChangedListener(captureAny))
        .captured[0]
        .call(LoginState.loggedOut);

    await tester.pump();

    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets(
      'Verify if "Create an invite" is displayed when user is logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(const P2PCopyPaste());

    verify(mockAuthenticationService.setOnLoginStateChangedListener(captureAny))
        .captured[0]
        .call(LoginState.loggedIn);

    await tester.pump();

    expect(find.text('Create an invite'), findsOneWidget);
  });

  testWidgets(
      'Verify if Privacy policy is displayed when user taps "Get started"',
      (WidgetTester tester) async {
    await tester.pumpWidget(const P2PCopyPaste());

    verify(mockAuthenticationService.setOnLoginStateChangedListener(captureAny))
        .captured[0]
        .call(LoginState.loggedOut);

    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pump();

    expect(find.byType(CancelConfirmDialog), findsOneWidget);
  });

  testWidgets('Verify if Privacy policy is dismissed when user disagrees',
      (WidgetTester tester) async {
    await tester.pumpWidget(const P2PCopyPaste());

    verify(mockAuthenticationService.setOnLoginStateChangedListener(captureAny))
        .captured[0]
        .call(LoginState.loggedOut);

    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pump();

    expect(find.byType(CancelConfirmDialog), findsOneWidget);

    await tester.tap(find.text('Disagree'));
    await tester.pump();

    expect(find.byType(CancelConfirmDialog), findsNothing);
  });

  testWidgets('Verify sign in when user agrees with privacy policy',
      (WidgetTester tester) async {
    await tester.pumpWidget(const P2PCopyPaste());

    verify(mockAuthenticationService.setOnLoginStateChangedListener(captureAny))
        .captured[0]
        .call(LoginState.loggedOut);

    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pump();

    expect(find.byType(CancelConfirmDialog), findsOneWidget);

    await tester.tap(find.text('Agree'));
    await tester.pump();

    verify(mockAuthenticationService.signInAnonymously()).called(1);
  });
}
