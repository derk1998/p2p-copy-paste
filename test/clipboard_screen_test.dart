import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';

import 'clipboard_screen_test.mocks.dart';

@GenerateMocks([IConnectionService, IClipboardService])
void main() {
  late ClipboardScreenViewModel viewModel;
  late MockIConnectionService mockConnectionService;
  late MockIClipboardService mockClipboardService;

  setUp(() {
    mockConnectionService = MockIConnectionService();
    mockClipboardService = MockIClipboardService();

    viewModel = ClipboardScreenViewModel(
        clipboardService: WeakReference(mockClipboardService),
        connectionService: WeakReference(mockConnectionService));

    viewModel.init();
  });

  test('Verify if clipboard is initialized empty', () async {
    final state = await viewModel.state.first;

    expect(state.clipboard, '');
  });

  test('Verify if clipboard is updated when data is received', () async {
    var state = await viewModel.state.first;

    final listener =
        verify(mockConnectionService.setOnReceiveDataListener(captureAny))
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
        verify(mockConnectionService.setOnReceiveDataListener(captureAny))
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

    await untilCalled(mockConnectionService.sendData('test'));
  });
}
