//These tests are now all flow tests
/*

@GenerateMocks(
    [IJoinConnectionService, INavigator, IJoinInviteService, IClipboardService])
void main() {
  late BasicViewModel viewModel;
  late MockIJoinInviteService mockJoinInviteService;
  late MockINavigator mockNavigator;
  late MockIJoinConnectionService mockJoinConnectionService;
  final invite = Invite('creator1234')..joiner = 'joiner1234';

  Widget onJoinNewInvitePageView() => const Scaffold();

  setUp(() {
    mockNavigator = MockINavigator();
    mockJoinInviteService = MockIJoinInviteService();
    mockJoinConnectionService = MockIJoinConnectionService();

    viewModel = BasicViewModel(
        invite: invite,
        getJoinNewInvitePageView: onJoinNewInvitePageView,
        clipboardService: MockIClipboardService(),
        joinConnectionService: mockJoinConnectionService,
        joinInviteService: mockJoinInviteService,
        navigator: mockNavigator);

    viewModel.init();
  });

  test('Verify if invite is joined during initialization', () async {
    verify(mockJoinInviteService.join(invite, any));
  });

  test('Verify state during initialization', () async {
    final state = await viewModel.state.first;

    expect(state.loading, isTrue);
    expect(state.description, isEmpty);
    expect(state.refreshButtonViewModel, isNull);
  });

  test('Verify if refresh button is displayed when invite is declined',
      () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    listener(invite, JoinInviteState.inviteDeclined);

    final state = await viewModel.state.first;

    expect(state.refreshButtonViewModel, isNotNull);
    expect(state.loading, false);
  });

  test('Verify if refresh button is displayed when invite is timed out',
      () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    listener(invite, JoinInviteState.inviteTimeout);

    final state = await viewModel.state.first;

    expect(state.refreshButtonViewModel, isNotNull);
    expect(state.loading, false);
  });

  test('Verify if refresh button is displayed when invite error occured',
      () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    listener(invite, JoinInviteState.inviteError);

    final state = await viewModel.state.first;

    expect(state.refreshButtonViewModel, isNotNull);
    expect(state.loading, false);
  });

  test('Verify if joiner is in the displayed text when invite is sent',
      () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    listener(invite, JoinInviteState.inviteSent);

    final state = await viewModel.state.first;

    expect(state.description.contains(invite.joiner!), isTrue);
    expect(state.refreshButtonViewModel, isNull);
    expect(state.loading, false);
  });

  test('Verify if connection is joined when invite is accepted', () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    listener(invite, JoinInviteState.inviteAccepted);

    await viewModel.state.first;

    verify(mockJoinConnectionService.joinConnection(invite.creator)).called(1);
  });

  test('Verify if screen is loading when invite is accepted', () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    listener(invite, JoinInviteState.inviteAccepted);

    final state = await viewModel.state.first;

    expect(state.loading, isTrue);
  });

  test(
      'Verify if error occures after invite is accepted then loading stops and refresh button is shown',
      () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    when(mockJoinConnectionService.joinConnection(invite.creator))
        .thenThrow(Error());

    listener(invite, JoinInviteState.inviteAccepted);

    await viewModel.state.first;

    // final connectedListener =
    //     verify(mockJoinConnectionService.setOnConnectedListener(captureAny))
    //         .captured[0];

    await untilCalled(mockJoinConnectionService.joinConnection(invite.creator));
    final state = await viewModel.state.first;

    expect(state.loading, isFalse);
    expect(state.refreshButtonViewModel, isNotNull);
  });

  test(
      'Verify if clipboard screen is shown when invite is accepted and connection is succesfully joined',
      () async {
    final listener =
        verify(mockJoinInviteService.join(invite, captureAny)).captured[0];

    when(mockJoinConnectionService.joinConnection(invite.creator))
        .thenThrow(Error());

    listener(invite, JoinInviteState.inviteAccepted);

    await viewModel.state.first;

    verify(mockJoinConnectionService.setOnConnectedListener(captureAny))
        .captured[0]();

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<ClipboardScreen>());
  });

}
*/
