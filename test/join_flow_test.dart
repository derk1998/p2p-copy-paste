import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:p2p_copy_paste/join/join_flow.dart';
import 'package:p2p_copy_paste/join/screens/join_connection.dart';
import 'package:p2p_copy_paste/join/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/join/view_models/scan_qr_code.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/screens/centered_description.dart';
import 'package:p2p_copy_paste/screens/restart.dart';

import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/view_models/basic.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';

import 'join_flow_test.mocks.dart';

@GenerateMocks(
    [IJoinInviteService, IConnectionService, Stream, StreamSubscription])
void main() {
  late MockIJoinInviteService mockJoinInviteService;
  late MockIConnectionService mockConnectionService;

  setUp(() {
    mockJoinInviteService = MockIJoinInviteService();
    mockConnectionService = MockIConnectionService();
  });

  test('Verify if join connection screen is shown when view type is code',
      () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.code);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<JoinConnectionScreen>());
  });

  test('Verify if scan qr code screen is shown when view type is camera',
      () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<ScanQRCodeScreen>());
  });

  test('Verify if invite is joined when valid invite is detected', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    final screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    const creatorName = 'creator';
    final timestamp = DateTime.now();

    viewModel.onQrCodeScanned(
        Invite(creator: creatorName, timestamp: timestamp).toJson());

    await untilCalled(mockJoinInviteService.join(any));
    final Invite capturedInvite =
        verify(mockJoinInviteService.join(captureAny)).captured[0];
    expect(capturedInvite.creator, creatorName);
    expect(capturedInvite.timestamp, timestamp);
  });

  test('Verify if flow is loading when joining invite', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite = Invite(creator: 'creator', timestamp: DateTime.now());

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    screen = await flow.viewChangeSubject.first;
    expect(screen, isNull);
  });

  test('Verify if verification screen is shown when invite is sent', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite = Invite(creator: 'creator', timestamp: DateTime.now());

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(
        JoinInviteUpdate(state: JoinInviteState.inviteSent, invite: invite));

    screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<CenteredDescriptionScreen>());
    expect(screen?.viewModel, isA<BasicViewModel>());
  });

  test('Verify if restart screen is shown when invite timed out', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite = Invite(creator: 'creator', timestamp: DateTime.now());

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(
        JoinInviteUpdate(state: JoinInviteState.inviteTimeout, invite: invite));

    screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<RestartScreen>());
    expect(screen?.viewModel, isA<RestartViewModel>());
  });

  test('Verify if start screen is shown when flow is restarted', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite = Invite(creator: 'creator', timestamp: DateTime.now());

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(
        JoinInviteUpdate(state: JoinInviteState.inviteTimeout, invite: invite));

    screen = await flow.viewChangeSubject.first;
    final restartViewModel = screen!.viewModel as RestartViewModel;
    restartViewModel.iconButtonViewModel.onPressed();

    await untilCalled(mockJoinInviteService.stream());
    screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<ScanQRCodeScreen>());
    expect(screen?.viewModel, isA<ScanQrCodeScreenViewModel>());
  });

  test('Verify if restart screen is shown when error occurred', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite = Invite(creator: 'creator', timestamp: DateTime.now());

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(
        JoinInviteUpdate(state: JoinInviteState.inviteError, invite: invite));

    screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<RestartScreen>());
    expect(screen?.viewModel, isA<RestartViewModel>());
  });

  test('Verify if restart screen is shown when invite is declined', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite = Invite(creator: 'creator', timestamp: DateTime.now());

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(JoinInviteUpdate(
        state: JoinInviteState.inviteDeclined, invite: invite));

    screen = await flow.viewChangeSubject.first;
    expect(screen?.view, isA<RestartScreen>());
    expect(screen?.viewModel, isA<RestartViewModel>());
  });

  test('Verify if visitor is set when invite is accepted', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite =
        Invite(creator: 'creator', timestamp: DateTime.now(), joiner: 'joiner');

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(JoinInviteUpdate(
        state: JoinInviteState.inviteAccepted, invite: invite));

    await untilCalled(mockConnectionService.setVisitor(any, any));
    final captured =
        verify(mockConnectionService.setVisitor(captureAny, captureAny))
            .captured;

    expect(captured[0], invite.joiner);
    expect(captured[1], invite.creator);
  });

  test('Verify if invite is accepted when visitor is set', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite =
        Invite(creator: 'creator', timestamp: DateTime.now(), joiner: 'joiner');

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(JoinInviteUpdate(
        state: JoinInviteState.inviteAccepted, invite: invite));

    await untilCalled(mockJoinInviteService.accept(any));
    final JoinerInvite? capturedInvite =
        verify(mockJoinInviteService.accept(captureAny)).captured[0];

    expect(capturedInvite!.joiner, invite.joiner);
    expect(capturedInvite.creator, invite.creator);
  });

  test('Verify if connection is joined when invite is accepted', () async {
    final flow = JoinFlow(
        joinConnectionService: WeakReference(mockConnectionService),
        joinInviteService: WeakReference(mockJoinInviteService),
        viewType: JoinViewType.camera);

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite =
        Invite(creator: 'creator', timestamp: DateTime.now(), joiner: 'joiner');

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(JoinInviteUpdate(
        state: JoinInviteState.inviteAccepted, invite: invite));

    await untilCalled(mockConnectionService.connect(any, any));
    final captured =
        verify(mockConnectionService.connect(captureAny, captureAny)).captured;

    expect(captured[0], invite.joiner);
    expect(captured[1], invite.creator);
  });

  test('Verify if flow completes when connected', () async {
    final completer = Completer<void>();
    bool completed = false;
    final flow = JoinFlow(
      joinConnectionService: WeakReference(mockConnectionService),
      joinInviteService: WeakReference(mockJoinInviteService),
      viewType: JoinViewType.camera,
      onCompleted: () async {
        completed = true;
        completer.complete();
      },
    );

    final mockStream = MockStream<JoinInviteUpdate>();
    when(mockJoinInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<JoinInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    flow.init();

    Screen? screen = await flow.viewChangeSubject.first;
    final viewModel = screen!.viewModel as ScanQrCodeScreenViewModel;
    final invite =
        Invite(creator: 'creator', timestamp: DateTime.now(), joiner: 'joiner');

    viewModel.onQrCodeScanned(invite.toJson());

    await untilCalled(mockJoinInviteService.join(any));

    final listener = verify(mockStream.listen(captureAny)).captured[0];
    listener(JoinInviteUpdate(
        state: JoinInviteState.inviteAccepted, invite: invite));

    await untilCalled(mockConnectionService.connect(any, any));
    final connectedListener =
        verify(mockConnectionService.setOnConnectedListener(captureAny))
            .captured[0];
    connectedListener();

    await completer.future;
    expect(completed, isTrue);
  });
}
