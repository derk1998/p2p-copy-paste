import 'dart:core';

import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/connect_dialog.dart';
import 'package:p2p_copy_paste/screens/join_connection.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/join_connection.dart';
import 'package:p2p_copy_paste/services/join_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/connect_dialog.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class JoinConnectionScreenState {
  JoinConnectionScreenState({this.loading = false, this.status = ''});

  bool loading;
  String status;
}

class JoinConnectionScreenViewModel extends StatefulScreenViewModel {
  late ButtonViewModel connectButtonViewModel;
  final String title = 'Join connection';

  JoinConnectionScreenViewModel(
      {required this.navigator,
      required this.clipboardService,
      required this.joinConnectionService,
      required this.joinInviteService}) {
    connectButtonViewModel = ButtonViewModel(
        title: 'Connect', onPressed: _onSubmitConnectionIdButtonClicked);
  }

  final INavigator navigator;
  final IClipboardService clipboardService;
  final IJoinConnectionService joinConnectionService;
  final IJoinInviteService joinInviteService;
  String code = '';

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
    final invite = Invite(code);
    //First some sanity checking
    _updateState('', loading: true);

    if (invite.creator.trim().isEmpty) {
      _updateState('ID must be valid');
      return;
    }

    navigator.replaceScreen(ConnectDialog(
      viewModel: ConnectDialogViewModel(
          invite: invite,
          navigator: navigator,
          getJoinNewInvitePageView: () => JoinConnectionScreen(
                viewModel: JoinConnectionScreenViewModel(
                    clipboardService: clipboardService,
                    joinConnectionService: joinConnectionService,
                    joinInviteService: joinInviteService,
                    navigator: navigator),
              ),
          clipboardService: clipboardService,
          joinConnectionService: joinConnectionService,
          joinInviteService: joinInviteService),
    ));
  }
}
