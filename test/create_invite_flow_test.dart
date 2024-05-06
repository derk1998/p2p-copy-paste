import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/create/create_flow.dart';
import 'package:p2p_copy_paste/create/screens/create_invite.dart';
import 'package:p2p_copy_paste/create/view_models/invite_expired.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/create/screens/invite_answered.dart';
import 'package:p2p_copy_paste/create/screens/invite_expired.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';

import 'create_invite_screen_test.mocks.dart';

@GenerateMocks([ICreateInviteService, Stream, StreamSubscription])
void main() {
  late MockICreateInviteService mockCreateInviteService;

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();
  });

  test('Verify if flow starts at create invite screen', () async {
    final flow = CreateFlow(createInviteService: mockCreateInviteService);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    ScreenView? view;
    final completer = Completer<void>();
    flow.viewChangeSubject.listen((value) {
      view = value;
      completer.complete();
    });

    flow.init();

    await completer.future;
    expect(view, isA<CreateInviteScreen>());
  });

  test('Verify if invite answered screen is shown when uid is received',
      () async {
    final flow = CreateFlow(createInviteService: mockCreateInviteService);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    ScreenView? view;
    final completer = Completer<void>();
    const int expectedScreenChanges = 2;
    int actualScreenChanges = 0;
    flow.viewChangeSubject.listen((value) {
      actualScreenChanges++;
      view = value;

      if (expectedScreenChanges == actualScreenChanges) {
        completer.complete();
      }
    });

    listener(CreateInviteUpdate(
        state: CreateInviteState.receivedUid,
        seconds: 60,
        invite: Invite('creator')..joiner = 'joiner'));

    await completer.future;
    expect(view, isA<InviteAnsweredScreen>());
  });

  test('Verify if invite expired screen is shown when expired', () async {
    final flow = CreateFlow(createInviteService: mockCreateInviteService);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    ScreenView? view;
    final completer = Completer<void>();
    const int expectedScreenChanges = 2;
    int actualScreenChanges = 0;
    flow.viewChangeSubject.listen((value) {
      actualScreenChanges++;
      view = value;

      if (expectedScreenChanges == actualScreenChanges) {
        completer.complete();
      }
    });

    listener(CreateInviteUpdate(
        state: CreateInviteState.expired,
        seconds: 60,
        invite: Invite('creator')..joiner = 'joiner'));

    await completer.future;
    expect(view, isA<InviteExpiredScreen>());
  });

  test('Verify if flow is canceled when invite is declined', () async {
    bool canceled = false;
    final completer = Completer<void>();

    final flow = CreateFlow(
      createInviteService: mockCreateInviteService,
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
        invite: Invite('creator')..joiner = 'joiner'));

    await completer.future;
    expect(canceled, isTrue);
  });

  test('Verify if flow is completed when invite is accepted', () async {
    bool completed = false;
    final completer = Completer<void>();

    final flow = CreateFlow(
      createInviteService: mockCreateInviteService,
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
        invite: Invite('creator')..joiner = 'joiner'));

    await completer.future;
    expect(completed, isTrue);
  });

  test('Verify if create invite screen is shown when expired and restarted',
      () async {
    //ugly test but it does what it's supposed to do, feel free to improve

    final flow = CreateFlow(createInviteService: mockCreateInviteService);

    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final listener = verify(mockStream.listen(captureAny)).captured[0];

    ScreenView? view;
    final completer = Completer<void>();
    final restartedCompleter = Completer<void>();

    const int expectedScreenChanges = 2;
    int actualScreenChanges = 0;
    flow.viewChangeSubject.listen((value) {
      actualScreenChanges++;
      view = value;

      if (expectedScreenChanges == actualScreenChanges) {
        completer.complete();
      } else if (expectedScreenChanges + 1 == actualScreenChanges) {
        restartedCompleter.complete();
      }
    });

    listener(CreateInviteUpdate(
        state: CreateInviteState.expired,
        seconds: 60,
        invite: Invite('creator')..joiner = 'joiner'));

    await completer.future;
    expect(view, isA<InviteExpiredScreen>());

    final inviteExpiredViewModel = view!.viewModel as InviteExpiredViewModel;
    inviteExpiredViewModel.iconButtonViewModel.onPressed();

    await restartedCompleter.future;
    expect(view, isA<CreateInviteScreen>());
  });
}
