import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/invite_answered.dart';

import 'invite_expired_screen_test.mocks.dart';

@GenerateMocks([
  ICreateInviteService,
  INavigator,
  ICreateConnectionService,
  IClipboardService
])
void main() {
  late InviteAnsweredScreenViewModel viewModel;
  late MockICreateInviteService mockCreateInviteService;
  late MockINavigator mockNavigator;
  late MockICreateConnectionService mockCreateConnectionService;
  final invite = Invite('creator')..joiner = 'joiner';

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();
    mockNavigator = MockINavigator();
    mockCreateConnectionService = MockICreateConnectionService();

    viewModel = InviteAnsweredScreenViewModel(
        invite: invite,
        createInviteService: mockCreateInviteService,
        navigator: mockNavigator,
        createConnectionService: mockCreateConnectionService,
        clipboardService: MockIClipboardService());
  });

  test('Verify if new connection is created when accept button is pressed',
      () async {
    when(mockCreateInviteService.accept(any))
        .thenAnswer((realInvocation) => Future(() => false));

    viewModel.acceptInviteButton.onPressed();

    verify(mockCreateConnectionService.startNewConnection());
  });

  test('Verify if invite is accepted when accept button is pressed', () async {
    when(mockCreateInviteService.accept(any))
        .thenAnswer((realInvocation) => Future(() => false));

    viewModel.acceptInviteButton.onPressed();
    await untilCalled(mockCreateInviteService.accept(invite));
  });

  test(
      'Verify if new connection is closed when invite is not succesfully accepted',
      () async {
    when(mockCreateInviteService.accept(any))
        .thenAnswer((realInvocation) => Future(() => false));

    viewModel.acceptInviteButton.onPressed();
    await untilCalled(mockCreateConnectionService.close());
  });

  test('Verify if clipboard screen is shown when connected', () async {
    when(mockCreateInviteService.accept(any))
        .thenAnswer((realInvocation) => Future(() => false));

    viewModel.acceptInviteButton.onPressed();

    verify(mockCreateConnectionService.setOnConnectedListener(captureAny))
        .captured[0]
        .call();

    expect(verify(mockNavigator.pushScreen(captureAny)).captured[0],
        isA<ClipboardScreen>());
  });

  test('Verify if screen is closed when decline button is pressed', () async {
    when(mockCreateInviteService.decline(any))
        .thenAnswer((realInvocation) => Future(() => true));

    viewModel.declineInviteButton.onPressed();

    verify(mockNavigator.popScreen()).called(1);
  });

  test('Verify if invite is declined when decline button is pressed', () async {
    when(mockCreateInviteService.decline(any))
        .thenAnswer((realInvocation) => Future(() => true));

    viewModel.declineInviteButton.onPressed();

    await untilCalled(mockCreateInviteService.decline(invite));
  });
}
