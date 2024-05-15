import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/config.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';

import 'join_invite_service_test.mocks.dart';

@GenerateMocks([
  IAuthenticationService,
  IInviteRepository,
  Stream,
  EventSink,
  StreamSubscription
])
void main() {
  late JoinInviteService joinInviteService;
  late MockIInviteRepository mockInviteRepository;
  late MockIAuthenticationService mockAuthenticationService;

  setUp(() {
    mockInviteRepository = MockIInviteRepository();
    mockAuthenticationService = MockIAuthenticationService();
    joinInviteService = JoinInviteService(
        inviteRepository: WeakReference(mockInviteRepository),
        authenticationService: WeakReference(mockAuthenticationService));
  });

  test('Verify if invite is retrieved based on local invite when joining',
      () async {
    final invite = Invite(creator: 'creator');

    when(mockInviteRepository.getInvite(invite.creator))
        .thenAnswer((realInvocation) => Future(() => invite));

    joinInviteService.join(invite);

    verify(mockInviteRepository.getInvite(invite.creator));
  });

  test('Verify if invite is updated with joiner from auth service when joining',
      () async {
    final invite = Invite(creator: 'creator');
    const String userId = 'userId1234';

    when(mockInviteRepository.getInvite(invite.creator))
        .thenAnswer((realInvocation) => Future(() => invite));

    when(mockAuthenticationService.getUserId()).thenReturn(userId);

    joinInviteService.join(invite);

    await untilCalled(mockAuthenticationService.getUserId());
    await untilCalled(mockInviteRepository.updateInvite(any));

    expect(
        verify(mockInviteRepository.updateInvite(captureAny))
            .captured[0]
            .joiner,
        userId);
  });

  test('Verify if invite status is updated to invite sent when invite is sent',
      () async {
    final invite = Invite(creator: 'creator');
    JoinInviteState? capturedInviteStatus;
    final completer = Completer<void>();

    when(mockInviteRepository.getInvite(invite.creator))
        .thenAnswer((realInvocation) => Future(() => invite));

    when(mockAuthenticationService.getUserId()).thenReturn('userid');

    joinInviteService.stream().listen((invite) {
      if (capturedInviteStatus == null) {
        capturedInviteStatus = invite.state;
        completer.complete();
      }
    });

    joinInviteService.join(invite);

    await completer.future;
    expect(capturedInviteStatus, JoinInviteState.inviteSent);
  });

  test(
      'Verify if invite status is updated to invite error when invite cannot be retrieved',
      () async {
    final invite = Invite(creator: 'creator');
    JoinInviteState? capturedInviteStatus;
    final completer = Completer<void>();

    when(mockInviteRepository.getInvite(invite.creator)).thenThrow(Error());

    when(mockAuthenticationService.getUserId()).thenReturn('userid');

    joinInviteService.stream().listen((invite) {
      if (capturedInviteStatus == null) {
        capturedInviteStatus = invite.state;
        completer.complete();
      }
    });

    joinInviteService.join(invite);

    await completer.future;
    expect(capturedInviteStatus, JoinInviteState.inviteError);
  });

  test('Verify if invite status is updated to timeout when invite is timed out',
      () async {
    final invite = Invite(creator: 'creator');
    JoinInviteState? capturedInviteStatus;
    final completer = Completer<void>();

    when(mockInviteRepository.getInvite(invite.creator))
        .thenAnswer((realInvocation) => Future(() => invite));

    when(mockAuthenticationService.getUserId()).thenReturn('userid');

    final mockStream = MockStream<Invite?>();
    final mockEventSink = MockEventSink<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(invite.creator))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.timeout(any, onTimeout: anyNamed('onTimeout')))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.listen(any, onError: anyNamed('onError')))
        .thenReturn(mockStreamSubscription);

    joinInviteService.stream().listen((invite) {
      if (capturedInviteStatus == null &&
          invite.state != JoinInviteState.inviteSent) {
        capturedInviteStatus = invite.state;
        completer.complete();
      }
    });

    joinInviteService.join(invite);
    await untilCalled(mockInviteRepository.snapshots(any));

    verify(mockStream.timeout(const Duration(seconds: kInviteTimeoutInSeconds),
            onTimeout: captureAnyNamed('onTimeout')))
        .captured[0](mockEventSink);

    await completer.future;
    expect(capturedInviteStatus, JoinInviteState.inviteTimeout);
  });

  test('Verify if invite status is updated to accepted when invite is accepted',
      () async {
    final invite = Invite(creator: 'creator');
    JoinInviteState? capturedInviteStatus;
    final completer = Completer<void>();

    when(mockInviteRepository.getInvite(invite.creator))
        .thenAnswer((realInvocation) => Future(() => invite));

    when(mockAuthenticationService.getUserId()).thenReturn('userid');

    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(invite.creator))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.timeout(any, onTimeout: anyNamed('onTimeout')))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.listen(any, onError: anyNamed('onError')))
        .thenReturn(mockStreamSubscription);

    joinInviteService.stream().listen((invite) {
      if (capturedInviteStatus == null &&
          invite.state != JoinInviteState.inviteSent) {
        capturedInviteStatus = invite.state;
        completer.complete();
      }
    });

    joinInviteService.join(invite);

    await untilCalled(mockInviteRepository.snapshots(any));

    verify(mockStream.listen(captureAny, onError: anyNamed('onError')))
        .captured[0](invite..acceptedByCreator = true);

    await completer.future;
    expect(capturedInviteStatus, JoinInviteState.inviteAccepted);
  });

  test('Verify if invite status is updated to declined when invite is declined',
      () async {
    final invite = Invite(creator: 'creator');
    JoinInviteState? capturedInviteStatus;
    final completer = Completer<void>();

    when(mockInviteRepository.getInvite(invite.creator))
        .thenAnswer((realInvocation) => Future(() => invite));

    when(mockAuthenticationService.getUserId()).thenReturn('userid');

    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(invite.creator))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.timeout(any, onTimeout: anyNamed('onTimeout')))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.listen(any, onError: anyNamed('onError')))
        .thenReturn(mockStreamSubscription);

    joinInviteService.stream().listen((invite) {
      if (capturedInviteStatus == null &&
          invite.state != JoinInviteState.inviteSent) {
        capturedInviteStatus = invite.state;
        completer.complete();
      }
    });

    joinInviteService.join(invite);

    await untilCalled(mockInviteRepository.snapshots(any));

    verify(mockStream.listen(captureAny, onError: anyNamed('onError')))
        .captured[0](invite..acceptedByCreator = false);

    await completer.future;
    expect(capturedInviteStatus, JoinInviteState.inviteDeclined);
  });

  test('Verify if invite status is updated to error when error occurred',
      () async {
    final invite = Invite(creator: 'creator');
    JoinInviteState? capturedInviteStatus;
    final completer = Completer<void>();

    when(mockInviteRepository.getInvite(invite.creator))
        .thenAnswer((realInvocation) => Future(() => invite));

    when(mockAuthenticationService.getUserId()).thenReturn('userid');

    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(invite.creator))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.timeout(any, onTimeout: anyNamed('onTimeout')))
        .thenAnswer((realInvocation) => mockStream);

    when(mockStream.listen(any, onError: anyNamed('onError')))
        .thenReturn(mockStreamSubscription);

    joinInviteService.stream().listen((invite) {
      if (capturedInviteStatus == null &&
          invite.state != JoinInviteState.inviteSent) {
        capturedInviteStatus = invite.state;
        completer.complete();
      }
    });

    joinInviteService.join(invite);

    await untilCalled(mockInviteRepository.snapshots(any));

    verify(mockStream.listen(any, onError: captureAnyNamed('onError')))
        .captured[0](Error());

    await completer.future;
    expect(capturedInviteStatus, JoinInviteState.inviteError);
  });
}
