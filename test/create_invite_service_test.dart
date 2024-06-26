import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';

import 'create_invite_service_test.mocks.dart';

@GenerateMocks(
    [IAuthenticationService, IInviteRepository, Stream, StreamSubscription])
void main() {
  late CreateInviteService createInviteService;
  late MockIInviteRepository mockInviteRepository;
  late MockIAuthenticationService mockAuthenticationService;

  setUp(() {
    mockInviteRepository = MockIInviteRepository();
    mockAuthenticationService = MockIAuthenticationService();
    createInviteService = CreateInviteService(
        inviteRepository: WeakReference(mockInviteRepository),
        authenticationService: WeakReference(mockAuthenticationService));
  });

  test('Verify if invite is updated when invite is declined', () async {
    final invite = CreatorInvite.fromInvite(Invite(creator: 'creator'));

    createInviteService.decline(invite);
    verify(mockInviteRepository.updateInvite(invite)).called(1);
  });

  test('Verify if invite is updated when declined', () async {
    final invite = CreatorInvite.fromInvite(Invite(creator: 'creator'));

    createInviteService.decline(invite);
    expect(invite.acceptedByCreator, false);
  });

  test('Verify if invite is updated when invite is accepted', () async {
    final invite = CreatorInvite.fromInvite(Invite(creator: 'creator'));

    createInviteService.accept(invite);
    verify(mockInviteRepository.updateInvite(invite)).called(1);
  });

  test('Verify if invite is updated when accepted', () async {
    final invite = CreatorInvite.fromInvite(Invite(creator: 'creator'));

    createInviteService.accept(invite);
    expect(invite.acceptedByCreator, true);
  });

  test('Verify if invite is created with user id from auth service', () async {
    final invite = Invite(creator: 'creator');
    const userId = 'userid1234';
    when(mockAuthenticationService.getUserId()).thenReturn(userId);
    when(mockInviteRepository.addInvite(any))
        .thenAnswer((realInvocation) => Future(() => invite));
    when(mockInviteRepository.deleteInvite(any))
        .thenAnswer((realInvocation) => Future(() {}));
    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(any)).thenAnswer(
      (realInvocation) => mockStream,
    );

    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    createInviteService.create();

    await untilCalled(mockInviteRepository.addInvite(any));

    verify(mockAuthenticationService.getUserId()).called(1);
    expect(
        verify(mockInviteRepository.addInvite(captureAny)).captured[0].creator,
        userId);
  });

  test('Verify if service listens to invite changes', () async {
    final invite = Invite(creator: 'creator');
    const userId = 'userid1234';
    when(mockAuthenticationService.getUserId()).thenReturn(userId);
    when(mockInviteRepository.addInvite(any))
        .thenAnswer((realInvocation) => Future(() => invite));
    when(mockInviteRepository.updateInvite(any))
        .thenAnswer((realInvocation) => Future(() => invite));
    when(mockInviteRepository.deleteInvite(any))
        .thenAnswer((realInvocation) => Future(() {}));
    final mockStream = MockStream<Invite?>();
    final mockStreamSubscription = MockStreamSubscription<Invite?>();

    when(mockInviteRepository.snapshots(any)).thenAnswer(
      (realInvocation) => mockStream,
    );

    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    createInviteService.create();
    await untilCalled(mockInviteRepository.snapshots(userId));
    verify(mockStream.listen(any)).called(1);
  });
}
