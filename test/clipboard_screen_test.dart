import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/use_cases/close_connection.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

import 'clipboard_screen_test.mocks.dart';

@GenerateMocks([
  TransceiveDataUseCase,
  INavigator,
  CloseConnectionUseCase,
  IClipboardService
])
void main() {
  late ClipboardScreenViewModel viewModel;
  late MockTransceiveDataUseCase mockTransceiveDataUseCase;
  late MockCloseConnectionUseCase mockCloseConnectionUseCase;
  late MockINavigator mockNavigator;
  late MockIClipboardService mockClipboardService;

  setUp(() {
    mockTransceiveDataUseCase = MockTransceiveDataUseCase();
    mockNavigator = MockINavigator();
    mockCloseConnectionUseCase = MockCloseConnectionUseCase();
    mockClipboardService = MockIClipboardService();

    viewModel = ClipboardScreenViewModel(
        closeConnectionUseCase: mockCloseConnectionUseCase,
        dataTransceiver: mockTransceiveDataUseCase,
        navigator: mockNavigator,
        clipboardService: mockClipboardService);

    viewModel.init();
  });

  test('Verify if clipboard is initialized empty', () async {
    final state = await viewModel.state.first;

    expect(state.clipboard, '');
  });

  test('Verify if clipboard is updated when data is received', () async {
    var state = await viewModel.state.first;

    final listener =
        verify(mockTransceiveDataUseCase.setOnReceiveDataListener(captureAny))
            .captured[0];

    listener('test');
    state = await viewModel.state.first;
    expect(state.clipboard, 'test');

    listener('test2');
    state = await viewModel.state.first;
    expect(state.clipboard, 'test2');
  });

  test(
      'Verify if clipboard is copied to device clipboard when copy button is pressed',
      () async {
    await viewModel.state.first;

    final listener =
        verify(mockTransceiveDataUseCase.setOnReceiveDataListener(captureAny))
            .captured[0];

    listener('test');
    await viewModel.state.first;

    viewModel.copyButtonViewModel.onPressed();
    verify(mockClipboardService.set('test')).called(1);
  });

  test(
      'Verify if device clipboard is pasted to clipboard when paste button is pressed',
      () async {
    await viewModel.state.first;

    final completer = Completer<void>();
    when(mockClipboardService.get()).thenAnswer((realInvocation) => Future(() {
          completer.complete();
          return 'test';
        }));

    viewModel.pasteButtonViewModel.onPressed();

    await completer.future;
    final state = await viewModel.state.first;
    expect(state.clipboard, 'test');
  });

  test(
      'Verify if device clipboard is send to peer when paste button is pressed',
      () async {
    await viewModel.state.first;

    when(mockClipboardService.get()).thenAnswer((realInvocation) => Future(() {
          return 'test';
        }));

    viewModel.pasteButtonViewModel.onPressed();

    await untilCalled(mockTransceiveDataUseCase.sendData('test'));
  });

  test('Verify if home screen is shown when connection closes', () async {
    await viewModel.state.first;

    verify(mockCloseConnectionUseCase.setOnConnectionClosedListener(captureAny))
        .captured[0]();

    verify(mockNavigator.goToHome()).called(1);
  });

  test('Verify if dialog is shown when back button is pressed', () async {
    await viewModel.state.first;

    viewModel.onBackPressed();

    verify(mockNavigator.pushDialog(captureAny)).captured[0];
  });

  test('Verify if dialog is dismissed when cancel button is pressed', () async {
    await viewModel.state.first;

    viewModel.onBackPressed();

    final CancelConfirmDialog dialog =
        verify(mockNavigator.pushDialog(captureAny)).captured[0];
    dialog.viewModel.cancelButtonViewModel.onPressed();
    verify(mockNavigator.popScreen());
  });

  test('Verify connection is closed when dialog confirm button is pressed',
      () async {
    await viewModel.state.first;

    viewModel.onBackPressed();

    final CancelConfirmDialog dialog =
        verify(mockNavigator.pushDialog(captureAny)).captured[0];
    dialog.viewModel.confirmButtonViewModel.onPressed();

    verify(mockCloseConnectionUseCase.close()).called(1);
  });
}
