import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/create/create_flow.dart';
import 'package:p2p_copy_paste/create/screens/create_invite.dart';
import 'package:p2p_copy_paste/features/clipboard.dart';
import 'package:p2p_copy_paste/features/create.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';

import 'package:p2p_copy_paste/screens/horizontal_menu.dart';
import 'package:p2p_copy_paste/screens/restart.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

import 'create_flow_test.mocks.dart';

@GenerateMocks([
  ICreateInviteService,
  IConnectionService,
  Stream,
  StreamSubscription,
  IClipboardService,
  ClipboardFeature,
  CreateFeature,
  INavigator,
])
void main() {
  late MockICreateInviteService mockCreateInviteService;
  late MockIConnectionService mockConnectionService;
  late MockIClipboardService mockClipboardService;
  late MockCreateFeature mockCreateFeature;
  late MockINavigator mockNavigator;
  late MockClipboardFeature mockClipboardFeature;

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();
    mockConnectionService = MockIConnectionService();
    mockClipboardService = MockIClipboardService();
    mockCreateFeature = MockCreateFeature();
    mockNavigator = MockINavigator();
    mockClipboardFeature = MockClipboardFeature();
  });

  test('Verify if flow starts at create invite screen', () async {
    final flow = CreateFlow(
        clipboardFeature: mockClipboardFeature,
        createFeature: mockCreateFeature,
        navigator: mockNavigator);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<CreateInviteScreen>());
  });

  test('Verify if invite answered screen is shown when uid is received',
      () async {
    final flow = CreateFlow(
        clipboardFeature: mockClipboardFeature,
        createFeature: mockCreateFeature,
        navigator: mockNavigator);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.receivedUid,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<HorizontalMenuScreen>());
  });

  test('Verify if invite expired screen is shown when expired', () async {
    final flow = CreateFlow(
        clipboardFeature: mockClipboardFeature,
        createFeature: mockCreateFeature,
        navigator: mockNavigator);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.expired,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<RestartScreen>());
  });

  test('Verify if flow is canceled when invite is declined', () async {
    bool canceled = false;
    final completer = Completer<void>();

    final flow = CreateFlow(
      clipboardFeature: mockClipboardFeature,
      createFeature: mockCreateFeature,
      navigator: mockNavigator,
      onCanceled: () async {
        canceled = true;
        completer.complete();
      },
    );

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.declined,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    await completer.future;
    expect(canceled, isTrue);
  });

  test('Verify if connecting when invite is accepted', () async {
    final flow = CreateFlow(
        clipboardFeature: mockClipboardFeature,
        createFeature: mockCreateFeature,
        navigator: mockNavigator);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    final invite = Invite(creator: 'creator', joiner: 'joiner');
    listener(CreateInviteUpdate(
        state: CreateInviteState.accepted, seconds: 60, invite: invite));

    await untilCalled(mockConnectionService.connect(any, any));

    verify(mockConnectionService.connect(invite.creator, invite.joiner));
  });

  test('Verify if clipboard screen is shown when connected', () async {
    final flow = CreateFlow(
        clipboardFeature: mockClipboardFeature,
        createFeature: mockCreateFeature,
        navigator: mockNavigator);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.accepted,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    final connectedListener =
        verify(mockConnectionService.setOnConnectedListener(captureAny))
            .captured[0];

    connectedListener();

    await untilCalled(mockClipboardFeature.addClipboardServiceListener(any));

    final clipboardServiceListener =
        verify(mockClipboardFeature.addClipboardServiceListener(captureAny))
            .captured[0];
    clipboardServiceListener.lock()?.call(WeakReference(mockClipboardService));

    Screen? screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<ClipboardScreen>());
  });

  test('Verify if cancel confirm dialog is shown when exiting clipboard screen',
      () async {
    final flow = CreateFlow(
        clipboardFeature: mockClipboardFeature,
        createFeature: mockCreateFeature,
        navigator: mockNavigator);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.accepted,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    final connectedListener =
        verify(mockConnectionService.setOnConnectedListener(captureAny))
            .captured[0];

    connectedListener();

    await untilCalled(mockClipboardFeature.addClipboardServiceListener(any));

    final clipboardServiceListener =
        verify(mockClipboardFeature.addClipboardServiceListener(captureAny))
            .captured[0];
    clipboardServiceListener.lock()?.call(WeakReference(mockClipboardService));

    Screen? screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<ClipboardScreen>());

    flow.onPopInvoked();

    await untilCalled(mockNavigator.pushDialog(any));

    final dialog = verify(mockNavigator.pushDialog(captureAny)).captured[0];

    expect(dialog, isA<CancelConfirmDialog>());
  });

  test('Verify if connection is closed when cancel confirm dialog is confirmed',
      () async {
    final flow = CreateFlow(
      clipboardFeature: mockClipboardFeature,
      createFeature: mockCreateFeature,
      navigator: mockNavigator,
    );

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.accepted,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    final connectedListener =
        verify(mockConnectionService.setOnConnectedListener(captureAny))
            .captured[0];

    connectedListener();

    await untilCalled(mockClipboardFeature.addClipboardServiceListener(any));

    final clipboardServiceListener =
        verify(mockClipboardFeature.addClipboardServiceListener(captureAny))
            .captured[0];
    clipboardServiceListener.lock()?.call(WeakReference(mockClipboardService));

    Screen? screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<ClipboardScreen>());

    flow.onPopInvoked();

    await untilCalled(mockNavigator.pushDialog(any));

    final dialog = verify(mockNavigator.pushDialog(captureAny)).captured[0]
        as CancelConfirmDialog;

    dialog.viewModel.confirmButtonViewModel.onPressed();

    await untilCalled(mockConnectionService.close());

    verify(mockConnectionService.close());
  });

  test('Verify if flow completes when connection is closed', () async {
    bool completed = false;
    final completer = Completer<void>();
    final flow = CreateFlow(
      clipboardFeature: mockClipboardFeature,
      createFeature: mockCreateFeature,
      navigator: mockNavigator,
      onCompleted: () async {
        completed = true;
        completer.complete();
      },
    );

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.accepted,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    final connectedListener =
        verify(mockConnectionService.setOnConnectedListener(captureAny))
            .captured[0];

    connectedListener();

    await untilCalled(mockClipboardFeature.addClipboardServiceListener(any));

    final clipboardServiceListener =
        verify(mockClipboardFeature.addClipboardServiceListener(captureAny))
            .captured[0];
    clipboardServiceListener.lock()?.call(WeakReference(mockClipboardService));

    Screen? screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<ClipboardScreen>());

    verify(mockConnectionService.setOnDisconnectedListener(captureAny))
        .captured[0]();

    await completer.future;

    expect(completed, isTrue);
  });

  test('Verify if create invite screen is shown when expired and restarted',
      () async {
    final flow = CreateFlow(
        clipboardFeature: mockClipboardFeature,
        createFeature: mockCreateFeature,
        navigator: mockNavigator);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final createConnectionServiceListener =
        verify(mockCreateFeature.addCreateConnectionServiceListener(captureAny))
            .captured[0];
    createConnectionServiceListener
        .lock()
        ?.call(WeakReference(mockConnectionService));

    final createInviteServiceListener =
        verify(mockCreateFeature.addCreateInviteServiceListener(captureAny))
            .captured[0];
    createInviteServiceListener
        .lock()
        ?.call(WeakReference(mockCreateInviteService));

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.expired,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    Screen? screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<RestartScreen>());

    final inviteExpiredViewModel = screen!.viewModel as RestartViewModel;
    inviteExpiredViewModel.iconButtonViewModel.onPressed();
    await untilCalled(mockCreateInviteService.stream());
    screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<CreateInviteScreen>());
  });
}
