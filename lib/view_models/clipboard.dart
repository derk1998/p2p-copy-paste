import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/services/connection.dart';
import 'package:flutter/services.dart' as services;
import 'package:test_webrtc/use_cases/close_connection.dart';
import 'package:test_webrtc/view_models/button.dart';
import 'package:test_webrtc/view_models/cancel_confirm.dart';
import 'package:test_webrtc/widgets/cancel_confirm_dialog.dart';

class ClipboardViewModelDependencies {
  ClipboardViewModelDependencies(
      {required this.dataTransceiver,
      required this.closeConnectionUseCase,
      required this.navigator});

  final DataTransceiver dataTransceiver;
  final CloseConnectionUseCase closeConnectionUseCase;
  final NavigatorState navigator;
}

class ClipboardViewModel
    extends FamilyAsyncNotifier<String, ClipboardViewModelDependencies> {
  late IconButtonViewModel copyButtonViewModel;
  late IconButtonViewModel pasteButtonViewModel;
  late DataTransceiver _dataTransceiver;
  late CloseConnectionUseCase _closeConnectionUseCase;
  late NavigatorState _navigator;

  @override
  FutureOr<String> build(ClipboardViewModelDependencies arg) {
    _closeConnectionUseCase = arg.closeConnectionUseCase;
    _closeConnectionUseCase.setOnConnectionClosedListener(_onConnectionClosed);

    _dataTransceiver = arg.dataTransceiver;
    _navigator = arg.navigator;
    _dataTransceiver.setOnReceiveDataListener(_onDataReceived);
    copyButtonViewModel = IconButtonViewModel(
        title: 'Copy', onPressed: _onCopyButtonPressed, icon: Icons.copy);
    pasteButtonViewModel = IconButtonViewModel(
        title: 'Paste', onPressed: _onPasteButtonPressed, icon: Icons.paste);

    return '';
  }

  void _onDataReceived(String data) {
    state = AsyncData(data);
  }

  void _onCopyButtonPressed() {
    if (state.hasValue) {
      services.Clipboard.setData(services.ClipboardData(text: state.value!));
    }
  }

  void _onPasteButtonPressed() async {
    final data = await services.Clipboard.getData('text/plain');

    if (data != null && data.text != null) {
      state = AsyncValue.data(data.text!);
      log('DATA: ${data.text!}');
      _dataTransceiver.sendData(data.text!);
    }
  }

  void _onConnectionClosed() {
    _navigator.popUntil((route) => route.isFirst);
  }

  void onBackPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final viewModel = CancelConfirmViewModel(
            title: 'Are you sure?',
            description: 'The connection will be lost',
            onCancelButtonPressed: () {
              Navigator.of(context).pop();
            },
            onConfirmButtonPressed: () {
              _closeConnectionUseCase.close();
            });
        return CancelConfirmDialog(viewModel: viewModel);
      },
    );
  }
}

final clipboardViewModelProvider = AsyncNotifierProviderFamily<
    ClipboardViewModel, String, ClipboardViewModelDependencies>(() {
  return ClipboardViewModel();
});
