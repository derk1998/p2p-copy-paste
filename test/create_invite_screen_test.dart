import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/invite_answered.dart';
import 'package:p2p_copy_paste/screens/invite_expired.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/create_invite.dart';

import 'create_invite_screen_test.mocks.dart';

@GenerateMocks([ICreateInviteService, INavigator, ICreateConnectionService])
void main() {
  late CreateInviteScreenViewModel viewModel;
  late MockICreateInviteService mockCreateInviteService;
  late MockINavigator mockNavigator;

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();
    mockNavigator = MockINavigator();

    viewModel = CreateInviteScreenViewModel(
        createInviteService: mockCreateInviteService,
        navigator: mockNavigator,
        createConnectionService: MockICreateConnectionService());

    viewModel.init();
  });

  test('Verify if initial state starts at loading', () async {
    final state = await viewModel.state.first;

    expect(state.loading, true);
  });

  test('Verify if invite is created at initialization', () async {
    verify(mockCreateInviteService.create(any, any)).called(1);
  });

  test('Verify if seconds are updated when waiting for invite response',
      () async {
    void Function(CreateInviteUpdate) listener =
        verify(mockCreateInviteService.create(captureAny, any)).captured[0];

    listener(CreateInviteUpdate(seconds: 60, state: CreateInviteState.waiting));
    var state = await viewModel.state.first;
    expect(state.seconds, 60);

    listener(CreateInviteUpdate(seconds: 50, state: CreateInviteState.waiting));
    state = await viewModel.state.first;
    expect(state.seconds, 50);
  });

  test('Verify if not loading when invite data is updated', () async {
    void Function(CreateInviteUpdate) listener =
        verify(mockCreateInviteService.create(captureAny, any)).captured[0];

    listener(CreateInviteUpdate(seconds: 60, state: CreateInviteState.waiting));
    var state = await viewModel.state.first;
    expect(state.loading, false);
  });

  test('Verify if invite expired screen is shown when invite is expired',
      () async {
    void Function(CreateInviteUpdate) listener =
        verify(mockCreateInviteService.create(captureAny, any)).captured[0];

    listener(CreateInviteUpdate(seconds: 60, state: CreateInviteState.expired));
    await viewModel.state.first;

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<InviteExpiredScreen>());
  });

  test('Verify if invite answered screen is shown when uid is received',
      () async {
    void Function(CreateInviteUpdate) listener =
        verify(mockCreateInviteService.create(captureAny, any)).captured[0];

    var invite = Invite('creator');
    invite.joiner = 'joiner';

    listener(CreateInviteUpdate(
        seconds: 60, state: CreateInviteState.receivedUid, invite: invite));
    await viewModel.state.first;

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<InviteAnsweredScreen>());
  });
}
