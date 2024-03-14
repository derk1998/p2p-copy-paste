import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/services/connection.dart';
import 'package:flutter/services.dart' as services;
import 'package:test_webrtc/view_models/button.dart';

class ClipboardViewModel extends FamilyAsyncNotifier<String, DataTransceiver> {
  late IconButtonViewModel copyButtonViewModel;
  late IconButtonViewModel pasteButtonViewModel;

  @override
  FutureOr<String> build(DataTransceiver arg) {
    _dataTransceiver = arg;
    _dataTransceiver!.setOnReceiveDataListener(_onDataReceived);
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
      _dataTransceiver!.sendData(data.text!);
    }
  }

  DataTransceiver? _dataTransceiver;
}

final clipboardViewModelProvider =
    AsyncNotifierProvider.family<ClipboardViewModel, String, DataTransceiver>(
        () {
  return ClipboardViewModel();
});
