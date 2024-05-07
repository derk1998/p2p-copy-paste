import 'dart:async';
import 'dart:core';

import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class JoinConnectionScreenState {
  JoinConnectionScreenState({this.loading = false, this.status = ''});

  bool loading;
  String status;
}

class JoinConnectionScreenViewModel extends StatefulScreenViewModel {
  late ButtonViewModel connectButtonViewModel;

  JoinConnectionScreenViewModel(
      {required this.joinInviteService,
      required this.inviteRetrievedCondition}) {
    connectButtonViewModel = ButtonViewModel(
        title: 'Connect', onPressed: _onSubmitConnectionIdButtonClicked);
  }

  final IJoinInviteService joinInviteService;
  String code = '';
  final StreamController<Invite> inviteRetrievedCondition;

  final _stateSubject = BehaviorSubject<JoinConnectionScreenState>.seeded(
      JoinConnectionScreenState());

  Stream<JoinConnectionScreenState> get state => _stateSubject;

  @override
  void init() {}

  @override
  void dispose() {
    _stateSubject.close();
  }

  void _updateState(String status, {bool loading = false}) {
    _stateSubject
        .add(JoinConnectionScreenState(status: status, loading: loading));
  }

  void _onSubmitConnectionIdButtonClicked() async {
    final invite = Invite(creator: code);
    //First some sanity checking
    _updateState('', loading: true);

    if (invite.creator.trim().isEmpty) {
      _updateState('ID must be valid');
      return;
    }

    inviteRetrievedCondition.add(invite);
  }

  @override
  String getTitle() {
    return 'Join connection';
  }
}
