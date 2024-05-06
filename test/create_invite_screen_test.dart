import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/create/view_models/create_invite.dart';

import 'create_invite_screen_test.mocks.dart';

@GenerateMocks([ICreateInviteService, Stream, StreamSubscription])
void main() {
  late CreateInviteScreenViewModel viewModel;
  late MockICreateInviteService mockCreateInviteService;

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();

    viewModel = CreateInviteScreenViewModel(
        createInviteService: mockCreateInviteService);
  });

  test('Verify if initial state starts at loading', () async {
    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    viewModel.init();

    final state = await viewModel.state.first;

    expect(state.loading, true);
  });

  test('Verify if invite is created at initialization', () async {
    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    viewModel.init();

    verify(mockCreateInviteService.create()).called(1);
  });

  test('Verify if seconds are updated when waiting for invite response',
      () async {
    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    viewModel.init();

    void Function(CreateInviteUpdate) listener =
        verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(seconds: 60, state: CreateInviteState.waiting));
    var state = await viewModel.state.first;
    expect(state.seconds, 60);

    listener(CreateInviteUpdate(seconds: 50, state: CreateInviteState.waiting));
    state = await viewModel.state.first;
    expect(state.seconds, 50);
  });

  test('Verify if not loading when invite data is updated', () async {
    final mockStream = MockStream<CreateInviteUpdate>();
    when(mockCreateInviteService.stream()).thenAnswer(
      (realInvocation) => mockStream,
    );

    final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
    when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

    viewModel.init();

    void Function(CreateInviteUpdate) listener =
        verify(mockStream.listen(captureAny)).captured[0];

    listener(CreateInviteUpdate(seconds: 60, state: CreateInviteState.waiting));
    var state = await viewModel.state.first;
    expect(state.loading, false);
  });

  //these are flow tests...
  // test('Verify if invite expired screen is shown when invite is expired',
  //     () async {
  //   final mockStream = MockStream<CreateInviteUpdate>();
  //   when(mockCreateInviteService.stream()).thenAnswer(
  //     (realInvocation) => mockStream,
  //   );

  //   final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
  //   when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

  //   viewModel.init();

  //   void Function(CreateInviteUpdate) listener =
  //       verify(mockStream.listen(captureAny)).captured[0];

  //   listener(CreateInviteUpdate(seconds: 60, state: CreateInviteState.expired));
  //   await viewModel.state.first;

  //   expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
  //       isA<InviteExpiredScreen>());
  // });

  // test('Verify if invite answered screen is shown when uid is received',
  //     () async {
  //   final mockStream = MockStream<CreateInviteUpdate>();
  //   when(mockCreateInviteService.stream()).thenAnswer(
  //     (realInvocation) => mockStream,
  //   );

  //   final mockStreamSubscription = MockStreamSubscription<CreateInviteUpdate>();
  //   when(mockStream.listen(any)).thenReturn(mockStreamSubscription);

  //   viewModel.init();

  //   void Function(CreateInviteUpdate) listener =
  //       verify(mockStream.listen(captureAny)).captured[0];

  //   var invite = Invite('creator');
  //   invite.joiner = 'joiner';

  //   listener(CreateInviteUpdate(
  //       seconds: 60, state: CreateInviteState.receivedUid, invite: invite));
  //   await viewModel.state.first;

  //   expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
  //       isA<InviteAnsweredScreen>());
  // });
}
