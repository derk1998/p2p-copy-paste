import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:flutter/services.dart' as services;
import 'package:p2p_copy_paste/use_cases/close_connection.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';

class ClipboardViewModelDependencies {
  ClipboardViewModelDependencies(
      {required this.dataTransceiver, required this.closeConnectionUseCase});

  final TransceiveDataUseCase dataTransceiver;
  final CloseConnectionUseCase closeConnectionUseCase;
}

class ClipboardViewModel
    extends FamilyAsyncNotifier<String, ClipboardViewModelDependencies> {
  late IconButtonViewModel copyButtonViewModel;
  late IconButtonViewModel pasteButtonViewModel;
  late TransceiveDataUseCase _dataTransceiver;
  late CloseConnectionUseCase _closeConnectionUseCase;

  @override
  FutureOr<String> build(ClipboardViewModelDependencies arg) {
    _closeConnectionUseCase = arg.closeConnectionUseCase;
    _closeConnectionUseCase.setOnConnectionClosedListener(_onConnectionClosed);

    _dataTransceiver = arg.dataTransceiver;
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
      _dataTransceiver.sendData(data.text!);
    }
  }

  void _onConnectionClosed() {
    GetIt.I.get<INavigator>().goToHome();
  }

  void onBackPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final viewModel = CancelConfirmViewModel(
            title: 'Are you sure?',
            description: 'The connection will be lost',
            onCancelButtonPressed: () {
              GetIt.I.get<INavigator>().popScreen();
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
