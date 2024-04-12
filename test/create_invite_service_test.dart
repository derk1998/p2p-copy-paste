import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/lifetime.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';

import 'create_invite_service_test.mocks.dart';

@GenerateMocks([
  IAuthenticationService,
  IInviteRepository,
  Stream,
  StreamSubscription,
  LifeTime
])
void main() {
  late CreateInviteService createInviteService;
  late MockIInviteRepository mockInviteRepository;
  late MockIAuthenticationService mockAuthenticationService;

  setUp(() {
    mockInviteRepository = MockIInviteRepository();
    mockAuthenticationService = MockIAuthenticationService();
    createInviteService = CreateInviteService(
        inviteRepository: mockInviteRepository,
        authenticationService: mockAuthenticationService);
  });

  test('Verify if add invite is called when invite is declined', () async {
    final invite = Invite('creator');

    createInviteService.decline(invite);
    verify(mockInviteRepository.addInvite(invite)).called(1);
  });

  test('Verify if invite is updated when declined', () async {
    final invite = Invite('creator');

    createInviteService.decline(invite);
    expect(invite.accepted, false);
  });

  test('Verify if add invite is called when invite is accepted', () async {
    final invite = Invite('creator');

    createInviteService.accept(invite);
    verify(mockInviteRepository.addInvite(invite)).called(1);
  });

  test('Verify if invite is updated when accepted', () async {
    final invite = Invite('creator');

    createInviteService.accept(invite);
    expect(invite.accepted, true);
  });

  test('Verify if expiring listener is set on lifetime when invite is created',
      () async {
    final mockLifeTime = MockLifeTime();
    final invite = Invite('creator');

    when(mockAuthenticationService.getUserId()).thenReturn('userid');
    when(mockInviteRepository.addInvite(any))
        .thenAnswer((realInvocation) => Future(() => invite));
    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(any)).thenAnswer(
      (realInvocation) => mockStream,
    );

    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    createInviteService.create((update) {}, WeakReference(mockLifeTime));

    verify(mockLifeTime.setOnExpiringListener(any)).called(1);
  });

  test('Verify if invite is created with user id from auth service', () async {
    final mockLifeTime = MockLifeTime();
    final invite = Invite('creator');
    const userId = 'userid1234';
    when(mockAuthenticationService.getUserId()).thenReturn(userId);
    when(mockInviteRepository.addInvite(any))
        .thenAnswer((realInvocation) => Future(() => invite));
    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(any)).thenAnswer(
      (realInvocation) => mockStream,
    );

    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    createInviteService.create((update) {}, WeakReference(mockLifeTime));

    verify(mockAuthenticationService.getUserId()).called(1);
    expect(
        verify(mockInviteRepository.addInvite(captureAny)).captured[0].creator,
        userId);
  });

  test('Verify if service listens to invite changes', () async {
    final mockLifeTime = MockLifeTime();
    final invite = Invite('creator');
    const userId = 'userid1234';
    when(mockAuthenticationService.getUserId()).thenReturn(userId);
    when(mockInviteRepository.addInvite(any))
        .thenAnswer((realInvocation) => Future(() => invite));
    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(any)).thenAnswer(
      (realInvocation) => mockStream,
    );

    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    createInviteService.create((update) {}, WeakReference(mockLifeTime));
    await untilCalled(mockInviteRepository.snapshots(userId));
    verify(mockStream.listen(any)).called(1);
  });
}
