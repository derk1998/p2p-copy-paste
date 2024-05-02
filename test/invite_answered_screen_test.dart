import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/create_invite/view_models/invite_answered.dart';

import 'invite_answered_screen_test.mocks.dart';

@GenerateMocks([ICreateInviteService])
void main() {
  late InviteAnsweredScreenViewModel viewModel;
  late MockICreateInviteService mockCreateInviteService;
  final invite = Invite('creator')..joiner = 'joiner';

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();

    viewModel = InviteAnsweredScreenViewModel(
        invite: invite, createInviteService: mockCreateInviteService);
  });

//todo: this must be tested in the outer flow later
  // test('Verify if new connection is created when accept button is pressed',
  //     () async {
  //   when(mockCreateInviteService.accept(any))
  //       .thenAnswer((realInvocation) => Future(() => false));

  //   viewModel.acceptInviteButton.onPressed();

  //   verify(mockCreateConnectionService.startNewConnection());
  // });

  test('Verify if invite is accepted when accept button is pressed', () async {
    when(mockCreateInviteService.accept(any))
        .thenAnswer((realInvocation) => Future(() => false));

    viewModel.acceptInviteButton.onPressed();
    await untilCalled(mockCreateInviteService.accept(invite));
  });

//todo: this must be tested in the outer flow later

  // test(
  //     'Verify if new connection is closed when invite is not succesfully accepted',
  //     () async {
  //   when(mockCreateInviteService.accept(any))
  //       .thenAnswer((realInvocation) => Future(() => false));

  //   viewModel.acceptInviteButton.onPressed();
  //   await untilCalled(mockCreateConnectionService.close());
  // });

//todo: this must be tested in the outer flow later

  // test('Verify if clipboard screen is shown when connected', () async {
  //   when(mockCreateInviteService.accept(any))
  //       .thenAnswer((realInvocation) => Future(() => false));

  //   viewModel.acceptInviteButton.onPressed();

  //   verify(mockCreateConnectionService.setOnConnectedListener(captureAny))
  //       .captured[0]
  //       .call();

  //   expect(verify(mockNavigator.pushScreen(captureAny)).captured[0],
  //       isA<ClipboardScreen>());
  // });

//todo: this must be tested in the outer flow later

  // test('Verify if screen is closed when decline button is pressed', () async {
  //   when(mockCreateInviteService.decline(any))
  //       .thenAnswer((realInvocation) => Future(() => true));

  //   viewModel.declineInviteButton.onPressed();

  //   verify(mockNavigator.popScreen()).called(1);
  // });

  test('Verify if invite is declined when decline button is pressed', () async {
    when(mockCreateInviteService.decline(any))
        .thenAnswer((realInvocation) => Future(() => true));

    viewModel.declineInviteButton.onPressed();

    await untilCalled(mockCreateInviteService.decline(invite));
  });
}
