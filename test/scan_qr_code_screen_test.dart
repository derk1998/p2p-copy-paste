import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/join/view_models/scan_qr_code.dart';

import 'scan_qr_code_screen_test.mocks.dart';

@GenerateMocks([IJoinInviteService, StreamController])
void main() {
  late ScanQrCodeScreenViewModel viewModel;
  late MockIJoinInviteService mockJoinInviteService;
  late MockStreamController<Invite> mockInviteRetrievedCondition;

  setUp(() {
    mockJoinInviteService = MockIJoinInviteService();
    mockInviteRetrievedCondition = MockStreamController<Invite>();

    viewModel = ScanQrCodeScreenViewModel(
        joinInviteService: mockJoinInviteService,
        inviteRetrievedCondition: mockInviteRetrievedCondition);

    viewModel.init();
  });

  test(
      'Verify if invite retrieved condition is valid when qr code is scanned with valid timestamp',
      () async {
    final invite = Invite(creator: 'creator')..timestamp = DateTime.now();
    final json = invite.toJson();

    viewModel.onQrCodeScanned(json);

    final Invite? capturedInvite =
        verify(mockInviteRetrievedCondition.add(captureAny)).captured[0];

    expect(capturedInvite, isNotNull);
    expect(invite.creator, capturedInvite?.creator);
  });

  test(
      'Verify if invite retrieved condition is not updated when qr code is scanned with invalid timestamp',
      () async {
    final invite = Invite(creator: 'creator');
    final json = invite.toJson();

    viewModel.onQrCodeScanned(json);

    verifyNever(mockInviteRetrievedCondition.add(any));
  });

//flow test
/*
  test(
      'Verify if scan qr code screen is displayed when refresh button is pressed in connect dialog',
      () async {
    final invite = Invite('creator')..timestamp = DateTime.now();
    final json = invite.toJson();

    viewModel.onQrCodeScanned(json);

    final CenteredDescriptionScreen connectDialog =
        verify(mockNavigator.replaceScreen(captureAny)).captured[0];

    connectDialog.viewModel.init();

    verify(mockJoinInviteService.join(any, captureAny)).captured[0](
        invite, JoinInviteState.inviteDeclined);

    final state = await connectDialog.viewModel.state.first;
    expect(state.refreshButtonViewModel, isNotNull);

    state.refreshButtonViewModel!.onPressed();

    expect(verify(mockNavigator.replaceScreen(captureAny)).captured[0],
        isA<ScanQRCodeScreen>());
  });
  */
}
