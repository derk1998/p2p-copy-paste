import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/create_invite.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/invite_expired.dart';

import 'invite_expired_screen_test.mocks.dart';

@GenerateMocks([ICreateInviteService, INavigator, ICreateConnectionService])
void main() {
  late InviteExpiredViewModel viewModel;
  late MockICreateInviteService mockCreateInviteService;
  late MockINavigator mockNavigator;

  setUp(() {
    mockCreateInviteService = MockICreateInviteService();
    mockNavigator = MockINavigator();

    viewModel = InviteExpiredViewModel(
        createInviteService: mockCreateInviteService,
        navigator: mockNavigator,
        createConnectionService: MockICreateConnectionService());
  });

  test('Verify if create invite screen is shown when refresh button is pressed',
      () async {
    viewModel.iconButtonViewModel.onPressed();

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<CreateInviteScreen>());
  });
}
