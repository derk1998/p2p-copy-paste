import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

//todo: split off join connection logic
class ConnectDialogState {
  ConnectDialogState(
      {this.description = '',
      this.refreshButtonViewModel,
      this.loading = false});

  final String description;
  PureIconButtonViewModel? refreshButtonViewModel;
  final bool loading;
}

class ConnectDialogViewModel extends ScreenViewModel {
  ConnectDialogViewModel(
      {required this.invite,
      required this.joinInviteService,
      required this.restartCondition});

  final Invite invite;
  final IJoinInviteService joinInviteService;
  final Subject<bool> restartCondition;

  final _stateSubject = BehaviorSubject<ConnectDialogState>.seeded(
      ConnectDialogState(loading: true));
  StreamSubscription<JoinInviteUpdate>? _joinInviteUpdateSubscription;

  Stream<ConnectDialogState> get state => _stateSubject;

  @override
  void init() {
    join(invite);
  }

  @override
  void dispose() {
    _stateSubject.close();
    _joinInviteUpdateSubscription?.cancel();
  }

  void _onRefreshButtonPressed() {
    restartCondition.add(true);
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

  void _onInviteStatusChanged(JoinInviteUpdate joinInviteUpdate) async {
    switch (joinInviteUpdate.state) {
      case JoinInviteState.inviteError:
        _updateState('The invite is invalid or outdated. Please try again.');
        break;
      case JoinInviteState.inviteTimeout:
        _updateState('The invite is expired. Please try again.');
        break;
      case JoinInviteState.inviteDeclined:
        _updateState(
            'The invite is declined by the other device. Please try again.');
        break;
      case JoinInviteState.inviteSent:
        _updateState(
            'Verify if the following code is displayed on the other device: ${joinInviteUpdate.invite.joiner}',
            refresh: false);
        break;
      default:
        break;
    }
  }

  Future<void> join(Invite invite) async {
    _joinInviteUpdateSubscription =
        joinInviteService.stream().listen(_onInviteStatusChanged);
    joinInviteService.join(invite);
  }

  @override
  String getTitle() {
    return 'Connecting';
  }
}
