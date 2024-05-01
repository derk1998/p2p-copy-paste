import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class ConnectDialogState {
  ConnectDialogState(
      {this.description = '',
      this.refreshButtonViewModel,
      this.loading = false});

  final String description;
  PureIconButtonViewModel? refreshButtonViewModel;
  final bool loading;
}

class ConnectDialogViewModel extends StatefulScreenViewModel {
  ConnectDialogViewModel(
      {required this.invite,
      required this.getJoinNewInvitePageView,
      required this.navigator,
      required this.joinInviteService,
      required this.joinConnectionService,
      required this.clipboardService});

  final Invite invite;
  Widget Function() getJoinNewInvitePageView;
  final INavigator navigator;
  final IJoinInviteService joinInviteService;
  final IJoinConnectionService joinConnectionService;
  final IClipboardService clipboardService;
  final _stateSubject = BehaviorSubject<ConnectDialogState>.seeded(
      ConnectDialogState(loading: true));

  Stream<ConnectDialogState> get state => _stateSubject;

  @override
  void init() {
    join(invite);
  }

  @override
  void dispose() {
    _stateSubject.close();
  }

  void _onRefreshButtonPressed() {
    navigator.replaceScreen(getJoinNewInvitePageView());
  }

  void _updateState(String description,
      {bool refresh = true, bool loading = false}) {
    return _stateSubject.add(
      ConnectDialogState(
          description: description,
          refreshButtonViewModel: refresh
              ? PureIconButtonViewModel(
                  icon: Icons.refresh, onPressed: _onRefreshButtonPressed)
              : null,
          loading: loading),
    );
  }

  void _connect(Invite invite) async {
    joinConnectionService.setOnConnectedListener(() {
      navigator.replaceScreen(ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            clipboardService: clipboardService,
            closeConnectionUseCase: joinConnectionService,
            dataTransceiver: joinConnectionService,
            navigator: navigator),
      ));
    });

    try {
      _updateState('', loading: true);
      await joinConnectionService.joinConnection(invite.creator);
    } catch (e) {
      _updateState('Unable to connect');
    }
  }

  void _onInviteStatusChanged(Invite invite, InviteStatus inviteStatus) async {
    switch (inviteStatus) {
      case InviteStatus.inviteAccepted:
        _connect(invite);
        break;
      case InviteStatus.inviteError:
        _updateState('The invite is invalid or outdated. Please try again.');
        break;
      case InviteStatus.inviteTimeout:
        _updateState('The invite is expired. Please try again.');
        break;
      case InviteStatus.inviteDeclined:
        _updateState(
            'The invite is declined by the other device. Please try again.');
        break;
      case InviteStatus.inviteSent:
        _updateState(
            'Verify if the following code is displayed on the other device: ${invite.joiner}',
            refresh: false);
        break;
    }
  }

  Future<void> join(Invite invite) async {
    joinInviteService.join(invite, _onInviteStatusChanged);
  }

  @override
  String title() {
    return 'Connecting';
  }
}
