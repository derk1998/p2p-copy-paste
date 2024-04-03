import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/services/login.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class ConnectDialogViewModelDependencies {
  ConnectDialogViewModelDependencies({
    required this.navigator,
    required this.invite,
    required this.getJoinNewInvitePageRoute,
  });

  final NavigatorState navigator;
  final Invite invite;
  MaterialPageRoute Function() getJoinNewInvitePageRoute;
}

class ConnectDialogViewModelData {
  ConnectDialogViewModelData(
      {required this.description, this.refreshButtonViewModel});

  final String description;
  PureIconButtonViewModel? refreshButtonViewModel;
}

class ConnectDialogViewModel extends AutoDisposeFamilyAsyncNotifier<
    ConnectDialogViewModelData?, ConnectDialogViewModelDependencies> {
  late NavigatorState _navigator;
  late Invite _invite;
  final String title = 'Connecting';
  late MaterialPageRoute Function() _getJoinNewInvitePageRoute;

  @override
  FutureOr<ConnectDialogViewModelData?> build(
      ConnectDialogViewModelDependencies arg) {
    _navigator = arg.navigator;
    _invite = arg.invite;
    _getJoinNewInvitePageRoute = arg.getJoinNewInvitePageRoute;
    join(_invite);
    return null;
  }

  void _onRefreshButtonPressed() {
    _navigator.pushReplacement(_getJoinNewInvitePageRoute());
  }

  AsyncData<ConnectDialogViewModelData?> _createData(String description,
      {bool refresh = true}) {
    return AsyncData(
      ConnectDialogViewModelData(
        description: description,
        refreshButtonViewModel: refresh
            ? PureIconButtonViewModel(
                icon: Icons.refresh, onPressed: _onRefreshButtonPressed)
            : null,
      ),
    );
  }

  void _connect(Invite invite) async {
    final connectionService = ref.read(joinConnectionServiceProvider);

    connectionService.setOnConnectedListener(() {
      _navigator.pushReplacement(MaterialPageRoute(
        builder: (context) => ClipboardScreen(
          closeConnectionUseCase: connectionService,
          dataTransceiver: connectionService,
          navigator: _navigator,
        ),
      ));
    });

    try {
      state = const AsyncLoading();
      await connectionService.joinConnection(invite.creator);
    } catch (e) {
      state = _createData('Unable to connect');
    }
  }

  void _onInviteStatusChanged(Invite invite, InviteStatus inviteStatus) async {
    switch (inviteStatus) {
      case InviteStatus.inviteAccepted:
        _connect(invite);
        break;
      case InviteStatus.inviteError:
        state =
            _createData('The invite is invalid or outdated. Please try again.');
        break;
      case InviteStatus.inviteTimeout:
        state = _createData('The invite is expired. Please try again.');
        break;
      case InviteStatus.inviteDeclined:
        state = _createData(
            'The invite is declined by the other device. Please try again.');
        break;
      case InviteStatus.inviteSent:
        String code = ref.read(loginServiceProvider).getUserId();
        state = _createData(
            'Verify if the following code is displayed on the other device: $code',
            refresh: false);
        break;
    }
  }

  Future<void> join(Invite invite) async {
    ref.read(joinInviteServiceProvider).join(
      invite,
      (inviteStatus) {
        _onInviteStatusChanged(invite, inviteStatus);
      },
    );
  }
}

final connectDialogViewModelProvider = AutoDisposeAsyncNotifierProviderFamily<
    ConnectDialogViewModel,
    ConnectDialogViewModelData?,
    ConnectDialogViewModelDependencies>(() {
  return ConnectDialogViewModel();
});
