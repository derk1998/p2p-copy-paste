import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class ClipboardScreenState {
  ClipboardScreenState({this.clipboard = ''});

  final String clipboard;
}

class ClipboardScreenViewModel
    extends DataScreenViewModel<ClipboardScreenState> {
  late ButtonViewModel copyButtonViewModel;
  late ButtonViewModel pasteButtonViewModel;

  ClipboardScreenViewModel(
      {required this.connectionService, required this.clipboardService}) {
    copyButtonViewModel = ButtonViewModel(
        title: 'Copy', onPressed: _onCopyButtonPressed, icon: Icons.copy);
    pasteButtonViewModel = ButtonViewModel(
        title: 'Paste', onPressed: _onPasteButtonPressed, icon: Icons.paste);
  }

  final WeakReference<IConnectionService> connectionService;
  final WeakReference<IClipboardService> clipboardService;

  @override
  void init() {
    super.init();
    connectionService.target!.setOnReceiveDataListener(_onDataReceived);
  }

  void _updateState(final String data) {
    publish(ClipboardScreenState(clipboard: data));
  }

  void _onDataReceived(String data) {
    _updateState(data);
  }

  void _onCopyButtonPressed() {
    clipboardService.target!.set(getLastPublishedValue().clipboard);
  }

  void _onPasteButtonPressed() async {
    final data = await clipboardService.target!.get();
    if (data != null) {
      _updateState(data);
      connectionService.target!.sendData(data);
    }
  }

  @override
  String getTitle() {
    return '';
  }

  @override
  ClipboardScreenState getEmptyState() {
    return ClipboardScreenState();
  }
}
