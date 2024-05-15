import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:p2p_copy_paste/models/invite.dart';

import 'package:p2p_copy_paste/join/view_models/join_connection.dart';

import 'join_connection_screen_test.mocks.dart';

@GenerateMocks([StreamController])
void main() {
  late JoinConnectionScreenViewModel viewModel;
  late MockStreamController<Invite> mockInviteRetrievedCondition;

  setUp(() {
    mockInviteRetrievedCondition = MockStreamController();

    viewModel = JoinConnectionScreenViewModel(
        inviteRetrievedCondition: mockInviteRetrievedCondition);

    viewModel.init();
  });

  test('Verify state is empty upon initialization', () async {
    final state = await viewModel.state.first;

    expect(state.loading, false);
    expect(state.status, '');
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
      'Verify if invite retrieved condition is valid when code is not empty and submit button is pressed',
      () async {
    viewModel.code = 'creator';
    viewModel.connectButtonViewModel.onPressed();

    final Invite? invite =
        verify(mockInviteRetrievedCondition.add(captureAny)).captured[0];

    expect(invite, isNotNull);
    expect(invite?.creator, viewModel.code);
  });
}
