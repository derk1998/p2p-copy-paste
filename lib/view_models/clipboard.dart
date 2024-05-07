import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class ClipboardScreenState {
  ClipboardScreenState({this.clipboard = ''});

  final String clipboard;
}

class ClipboardScreenViewModel implements StatefulScreenViewModel {
  late ButtonViewModel copyButtonViewModel;
  late ButtonViewModel pasteButtonViewModel;

  ClipboardScreenViewModel(
      {required this.dataTransceiver, required this.clipboardService}) {
    copyButtonViewModel = ButtonViewModel(
        title: 'Copy', onPressed: _onCopyButtonPressed, icon: Icons.copy);
    pasteButtonViewModel = ButtonViewModel(
        title: 'Paste', onPressed: _onPasteButtonPressed, icon: Icons.paste);
  }

  final _stateSubject =
      BehaviorSubject<ClipboardScreenState>.seeded(ClipboardScreenState());

  Stream<ClipboardScreenState> get state => _stateSubject;

  final TransceiveDataUseCase dataTransceiver;
  final IClipboardService clipboardService;

  @override
  void init() {
    dataTransceiver.setOnReceiveDataListener(_onDataReceived);
  }

  @override
  void dispose() {
    _stateSubject.close();
  }

  void _updateState(final String data) {
    _stateSubject.add(ClipboardScreenState(clipboard: data));
  }

  void _onDataReceived(String data) {
    log('data is received! -> $data');
    _updateState(data);
  }

  void _onCopyButtonPressed() {
    clipboardService.set(_stateSubject.value.clipboard);
  }

  void _onPasteButtonPressed() async {
    final data = await clipboardService.get();
    if (data != null) {
      log('data is $data');
      _updateState(data);
      dataTransceiver.sendData(data);
    }
  }

  @override
  String getTitle() {
    return '';
  }
}
