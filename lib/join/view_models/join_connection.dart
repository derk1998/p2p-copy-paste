import 'dart:async';
import 'dart:core';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class JoinConnectionScreenState {
  JoinConnectionScreenState({this.loading = false, this.status = ''});

  bool loading;
  String status;
}

class JoinConnectionScreenViewModel
    extends DataScreenViewModel<JoinConnectionScreenState> {
  late ButtonViewModel connectButtonViewModel;

  JoinConnectionScreenViewModel({required this.inviteRetrievedCondition}) {
    connectButtonViewModel = ButtonViewModel(
        title: 'Connect', onPressed: _onSubmitConnectionIdButtonClicked);
  }

  String code = '';
  final StreamController<Invite> inviteRetrievedCondition;

  void _updateState(String status, {bool loading = false}) {
    publish(JoinConnectionScreenState(status: status, loading: loading));
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

  @override
  JoinConnectionScreenState getEmptyState() {
    return JoinConnectionScreenState();
  }
}
