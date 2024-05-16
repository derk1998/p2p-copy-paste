import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/main_flow.dart';
import 'package:p2p_copy_paste/screens/vertical_menu.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/services/file.dart';

import 'package:p2p_copy_paste/system_manager.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

import 'main_flow_test.mocks.dart';

@GenerateMocks([
  ISystemManager,
  INavigator,
  IAuthenticationService,
  Stream,
  StreamSubscription,
  IFileService,
  IConnectionService,
  ICreateInviteService,
  IJoinInviteService,
  IClipboardService,
])
void main() {
  late MockISystemManager mockSystemManager;
  late MockINavigator mockNavigator;
  late MainFlow flow;

  setUp(() {
    mockSystemManager = MockISystemManager();
    mockNavigator = MockINavigator();
    flow = MainFlow(navigator: mockNavigator, systemManager: mockSystemManager);
  });

  test('Verify if flow starts at loading state', () async {
    flow.init();

    final screen = await flow.viewChangeSubject.first;
    expect(screen, isNull);
  });

  test('Verify if get started screen is shown when logged out', () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedOut);

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.viewModel, isA<MenuScreenViewModel>());
    expect(screen?.view, isA<VerticalMenuScreen>());
  });

  test('Verify if loading when logging in', () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggingIn);

    final screen = await flow.viewChangeSubject.first;
    expect(screen, isNull);
  });

  test('Verify if overview is shown when logged in', () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedIn);

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.viewModel, isA<MenuScreenViewModel>());
    expect(screen?.view, isA<VerticalMenuScreen>());
  });

  test(
      'Verify if privacy policy dialog is shown when get started button is pressed',
      () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedOut);

    final screen = await flow.viewChangeSubject.first;
    final menuScreenViewModel = screen!.viewModel as MenuScreenViewModel;

    menuScreenViewModel.buttonViewModelList[0].onPressed();

    final fileServiceListener =
        verify(mockSystemManager.addFileServiceListener(captureAny))
            .captured[0];

    final mockFileService = MockIFileService();
    when(mockFileService.loadFile(any))
        .thenAnswer((realInvocation) => Future<String>(() => ''));

    fileServiceListener.lock()?.call(WeakReference(mockFileService));

    await untilCalled(mockNavigator.pushDialog(any));

    final capturedView =
        verify(mockNavigator.pushDialog(captureAny)).captured[0];
    expect(capturedView, isA<CancelConfirmDialog>());
  });

  test(
      'Verify if privacy policy dialog is closed when cancel button is pressed',
      () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedOut);

    final screen = await flow.viewChangeSubject.first;
    final menuScreenViewModel = screen!.viewModel as MenuScreenViewModel;

    menuScreenViewModel.buttonViewModelList[0].onPressed();

    final fileServiceListener =
        verify(mockSystemManager.addFileServiceListener(captureAny))
            .captured[0];

    final mockFileService = MockIFileService();
    when(mockFileService.loadFile(any))
        .thenAnswer((realInvocation) => Future<String>(() => ''));

    fileServiceListener.lock()?.call(WeakReference(mockFileService));

    await untilCalled(mockNavigator.pushDialog(any));

    final CancelConfirmDialog capturedView =
        verify(mockNavigator.pushDialog(captureAny)).captured[0];
    capturedView.viewModel.cancelButtonViewModel.onPressed();

    await untilCalled(mockNavigator.popScreen());
    verify(mockNavigator.popScreen());
  });

  test('Verify if signing in when privacy policy is accepted', () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedOut);

    final screen = await flow.viewChangeSubject.first;
    final menuScreenViewModel = screen!.viewModel as MenuScreenViewModel;

    menuScreenViewModel.buttonViewModelList[0].onPressed();

    final fileServiceListener =
        verify(mockSystemManager.addFileServiceListener(captureAny))
            .captured[0];

    final mockFileService = MockIFileService();
    when(mockFileService.loadFile(any))
        .thenAnswer((realInvocation) => Future<String>(() => ''));

    fileServiceListener.lock()?.call(WeakReference(mockFileService));

    await untilCalled(mockNavigator.pushDialog(any));

    final CancelConfirmDialog capturedView =
        verify(mockNavigator.pushDialog(captureAny)).captured[0];
    capturedView.viewModel.confirmButtonViewModel.onPressed();

    verify(mockAuthenticationService.signInAnonymously());
  });

  test('Verify if flow is loading after create button pressed', () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedIn);

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as MenuScreenViewModel;
    viewModel.buttonViewModelList[0].onPressed();

    screen = await flow.viewChangeSubject.first;
    expect(screen, isNull);
  });

  test('Verify if create flow screen is shown when create button is pressed',
      () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedIn);

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as MenuScreenViewModel;
    viewModel.buttonViewModelList[0].onPressed();

    final createConnectionServiceListener =
        verify(mockSystemManager.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    final mockConnectionService = MockIConnectionService();
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockSystemManager.addCreateInviteServiceListener(captureAny))
            .captured[0];
    final mockCreateInviteService = MockICreateInviteService();
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final capturedView =
        verify(mockNavigator.pushScreen(captureAny)).captured[0];
    expect(capturedView, isA<FlowScreen>());
  });

  test('Verify if flow is loading after join button pressed', () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedIn);

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as MenuScreenViewModel;
    viewModel.buttonViewModelList[1].onPressed();

    screen = await flow.viewChangeSubject.first;
    expect(screen, isNull);
  });

  test('Verify if join flow screen is shown when join button is pressed',
      () async {
    flow.init();

    await untilCalled(mockSystemManager.addAuthenticationServiceListener(any));

    final authenticationServiceListener =
        verify(mockSystemManager.addAuthenticationServiceListener(captureAny))
            .captured[0];

    final mockAuthenticationService = MockIAuthenticationService();
    final mockLoginStateStream = MockStream<LoginState>();
    when(mockAuthenticationService.stream())
        .thenAnswer((realInvocation) => mockLoginStateStream);

    final mockLoginStateStreamSubscription =
        MockStreamSubscription<LoginState>();
    when(mockLoginStateStream.listen(any))
        .thenReturn(mockLoginStateStreamSubscription);

    authenticationServiceListener
        .lock()
        ?.call(WeakReference(mockAuthenticationService));

    await untilCalled(mockLoginStateStream.listen(any));

    final loginStateListener =
        verify(mockLoginStateStream.listen(captureAny)).captured[0];

    loginStateListener(LoginState.loggedIn);

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as MenuScreenViewModel;
    viewModel.buttonViewModelList[1].onPressed();

    final joinConnectionServiceListener =
        verify(mockSystemManager.addJoinConnectionServiceListener(captureAny))
            .captured[0];
    final mockConnectionService = MockIConnectionService();
    joinConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final joinInviteServiceListener =
        verify(mockSystemManager.addJoinInviteServiceListener(captureAny))
            .captured[0];
    final mockJoinInviteService = MockIJoinInviteService();
    joinInviteServiceListener
        .lock()
        ?.call(WeakReference(mockJoinInviteService));

    final capturedView =
        verify(mockNavigator.pushScreen(captureAny)).captured[0];
    expect(capturedView, isA<FlowScreen>());
  });
}
