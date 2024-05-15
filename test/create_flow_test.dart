import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/create/create_flow.dart';
import 'package:p2p_copy_paste/create/screens/create_invite.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/screens/horizontal_menu.dart';
import 'package:p2p_copy_paste/screens/restart.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';

import 'create_flow_test.mocks.dart';

@GenerateMocks(
    [ICreateInviteService, IConnectionService, Stream, StreamSubscription])
void main() {
  late MockICreateInviteService mockCreateInviteService;
  late MockIConnectionService mockConnectionService;

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();
    mockConnectionService = MockIConnectionService();
  });

  test('Verify if flow starts at create invite screen', () async {
    final flow = CreateFlow(
        createInviteService: WeakReference(mockCreateInviteService),
        createConnectionService: WeakReference(mockConnectionService));

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<CreateInviteScreen>());
  });

  test('Verify if invite answered screen is shown when uid is received',
      () async {
    final flow = CreateFlow(
        createInviteService: WeakReference(mockCreateInviteService),
        createConnectionService: WeakReference(mockConnectionService));

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

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
        createInviteService: WeakReference(mockCreateInviteService),
        createConnectionService: WeakReference(mockConnectionService));

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

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
      createInviteService: WeakReference(mockCreateInviteService),
      createConnectionService: WeakReference(mockConnectionService),
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
      createInviteService: WeakReference(mockCreateInviteService),
      createConnectionService: WeakReference(mockConnectionService),
    );

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    final invite = Invite(creator: 'creator', joiner: 'joiner');
    listener(CreateInviteUpdate(
        state: CreateInviteState.accepted, seconds: 60, invite: invite));

    await untilCalled(mockConnectionService.connect(any, any));

    verify(mockConnectionService.connect(invite.creator, invite.joiner));
  });

  test('Verify if flow is completed when connected', () async {
    bool completed = false;
    final completer = Completer<void>();

    final flow = CreateFlow(
      createInviteService: WeakReference(mockCreateInviteService),
      createConnectionService: WeakReference(mockConnectionService),
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

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(
        state: CreateInviteState.accepted,
        seconds: 60,
        invite: Invite(creator: 'creator', joiner: 'joiner')));

    final connectedListener =
        verify(mockConnectionService.setOnConnectedListener(captureAny))
            .captured[0];

    connectedListener();

    await completer.future;
    expect(completed, isTrue);
  });

  test('Verify if create invite screen is shown when expired and restarted',
      () async {
    final flow = CreateFlow(
        createInviteService: WeakReference(mockCreateInviteService),
        createConnectionService: WeakReference(mockConnectionService));

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

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
