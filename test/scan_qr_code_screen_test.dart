import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/connect_dialog.dart';
import 'package:p2p_copy_paste/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/view_models/scan_qr_code.dart';

import 'scan_qr_code_screen_test.mocks.dart';

@GenerateMocks(
    [IJoinConnectionService, INavigator, IJoinInviteService, IClipboardService])
void main() {
  late ScanQrCodeScreenViewModel viewModel;
  late MockIJoinInviteService mockJoinInviteService;
  late MockINavigator mockNavigator;

  setUp(() {
    mockNavigator = MockINavigator();
    mockJoinInviteService = MockIJoinInviteService();

    viewModel = ScanQrCodeScreenViewModel(
        clipboardService: MockIClipboardService(),
        joinConnectionService: MockIJoinConnectionService(),
        joinInviteService: mockJoinInviteService,
        navigator: mockNavigator);

    viewModel.init();
  });

  test(
      'Verify if connect dialog is shown when qr code is scanned with valid timestamp',
      () async {
    final invite = Invite('creator')..timestamp = DateTime.now();
    final json = invite.toJson();

    viewModel.onQrCodeScanned(json);

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<ConnectDialog>());
  });

  test(
      'Verify if connect dialog is not shown when qr code is scanned with invalid timestamp',
      () async {
    final invite = Invite('creator');
    final json = invite.toJson();

    viewModel.onQrCodeScanned(json);

    verifyNever(mockNavigator.replaceScreen(any));
  });

  test(
      'Verify if scan qr code screen is displayed when refresh button is pressed in connect dialog',
      () async {
    final invite = Invite('creator')..timestamp = DateTime.now();
    final json = invite.toJson();

    viewModel.onQrCodeScanned(json);

    final ConnectDialog connectDialog =
        verify(mockNavigator.replaceScreen(captureAny)).captured[0];

    connectDialog.viewModel.init();

    verify(mockJoinInviteService.join(any, captureAny))
        .captured[0](InviteStatus.inviteDeclined);

    final state = await connectDialog.viewModel.state.first;
    expect(state.refreshButtonViewModel, isNotNull);

    state.refreshButtonViewModel!.onPressed();

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<ScanQRCodeScreen>());
  });
}
