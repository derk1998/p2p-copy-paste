import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/centered_description.dart';
import 'package:p2p_copy_paste/join/screens/join_connection.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/join/services/join_connection.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/join/view_models/join_connection.dart';

import 'join_connection_screen_test.mocks.dart';

@GenerateMocks(
    [IJoinConnectionService, INavigator, IJoinInviteService, IClipboardService])
void main() {
  late JoinConnectionScreenViewModel viewModel;
  late MockIJoinInviteService mockJoinInviteService;
  late MockINavigator mockNavigator;

  setUp(() {
    mockNavigator = MockINavigator();
    mockJoinInviteService = MockIJoinInviteService();

    viewModel = JoinConnectionScreenViewModel(
        clipboardService: MockIClipboardService(),
        joinConnectionService: MockIJoinConnectionService(),
        joinInviteService: mockJoinInviteService,
        navigator: mockNavigator);

    viewModel.init();
  });

  test('Verify state is empty upon initialization', () async {
    final state = await viewModel.state.first;

    expect(state.loading, false);
    expect(state.status, '');
  });

  test(
      'Verify if connect dialog is not shown when code is empty and submit button is pressed',
      () async {
    viewModel.code = '';
    viewModel.connectButtonViewModel.onPressed();

    verifyNever(mockNavigator.replaceScreen(any));
  });

  test(
      'Verify if error message is shown when code is empty and submit button is pressed',
      () async {
    viewModel.code = '';
    viewModel.connectButtonViewModel.onPressed();

    final state = await viewModel.state.first;

    expect(state.status, 'ID must be valid');
  });

  test(
      'Verify if connect dialog is shown when code is not empty and submit button is pressed',
      () async {
    viewModel.code = 'creator';
    viewModel.connectButtonViewModel.onPressed();

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<CenteredDescriptionScreen>());
  });

  test(
      'Verify if join connection screen is displayed when refresh button is pressed in connect dialog',
      () async {
    viewModel.code = 'creator';
    viewModel.connectButtonViewModel.onPressed();

    final CenteredDescriptionScreen connectDialog =
        verify(mockNavigator.replaceScreen(captureAny)).captured[0];

    connectDialog.viewModel.init();

    verify(mockJoinInviteService.join(any, captureAny)).captured[0](
        Invite(viewModel.code), JoinInviteState.inviteDeclined);

    final state = await connectDialog.viewModel.state.first;
    expect(state.refreshButtonViewModel, isNotNull);

    state.refreshButtonViewModel!.onPressed();

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<JoinConnectionScreen>());
  });
}
