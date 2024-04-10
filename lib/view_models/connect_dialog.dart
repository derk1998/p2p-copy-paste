import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class ConnectDialogViewModelDependencies {
  ConnectDialogViewModelDependencies({
    required this.invite,
    required this.getJoinNewInvitePageView,
  });

  final Invite invite;
  Widget Function() getJoinNewInvitePageView;
}

class ConnectDialogViewModelData {
  ConnectDialogViewModelData(
      {required this.description, this.refreshButtonViewModel});

  final String description;
  PureIconButtonViewModel? refreshButtonViewModel;
}

class ConnectDialogViewModel extends AutoDisposeFamilyAsyncNotifier<
    ConnectDialogViewModelData?, ConnectDialogViewModelDependencies> {
  late Invite _invite;
  final String title = 'Connecting';
  late Widget Function() _getJoinNewInvitePageView;

  @override
  FutureOr<ConnectDialogViewModelData?> build(
      ConnectDialogViewModelDependencies arg) {
    _invite = arg.invite;
    _getJoinNewInvitePageView = arg.getJoinNewInvitePageView;
    join(_invite);
    return null;
  }

  void _onRefreshButtonPressed() {
    GetIt.I.get<INavigator>().replaceScreen(_getJoinNewInvitePageView());
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
    // final connectionService = ref.read(joinConnectionServiceProvider);

    // connectionService.setOnConnectedListenerImpl(() {
    //   GetIt.I.get<INavigator>().replaceScreen(ClipboardScreen(
    //         closeConnectionUseCase: connectionService,
    //         dataTransceiver: connectionService,
    //       ));
    // });

    // try {
    //   state = const AsyncLoading();
    //   await connectionService.joinConnection(invite.creator);
    // } catch (e) {
    //   state = _createData('Unable to connect');
    // }
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
        String code = GetIt.I.get<IAuthenticationService>().getUserId();
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
