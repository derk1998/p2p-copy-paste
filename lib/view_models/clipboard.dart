import 'dart:async';
import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/services/connection_service.dart';
import 'package:flutter/services.dart' as services;

class ClipboardViewModel extends FamilyAsyncNotifier<String, DataTransceiver> {
  @override
  FutureOr<String> build(DataTransceiver arg) {
    _dataTransceiver = arg;
    _dataTransceiver!.setOnReceiveDataListener(_onDataReceived);
    return '';
  }

  void _onDataReceived(String data) {
    state = AsyncData(data);
  }

  void onCopyButtonPressed() {
    if (state.hasValue) {
      services.Clipboard.setData(services.ClipboardData(text: state.value!));
    }
  }

  void onPasteButtonPressed() async {
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
