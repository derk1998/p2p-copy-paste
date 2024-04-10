import 'dart:async';
import 'dart:core';

import 'package:p2p_copy_paste/lifetime.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/invite_answered.dart';
import 'package:p2p_copy_paste/screens/invite_expired.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/invite_answered.dart';
import 'package:p2p_copy_paste/view_models/invite_expired.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class CreateInviteScreenState {
  CreateInviteScreenState({this.data, this.seconds, this.loading = true});

  int? seconds;
  String? data;
  bool loading;

  CreateInviteScreenState copyWith({
    int? seconds,
    String? data,
    required bool loading,
  }) {
    return CreateInviteScreenState(
        seconds: seconds ?? this.seconds,
        data: data ?? this.data,
        loading: loading);
  }
}

class CreateInviteScreenViewModel extends StatefulScreenViewModel
    with LifeTime {
  final String title = 'Create an invite';

  CreateInviteScreenViewModel(
      {required this.navigator,
      required this.createInviteService,
      required this.createConnectionService});

  final INavigator navigator;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  final _stateSubject = BehaviorSubject<CreateInviteScreenState>.seeded(
      CreateInviteScreenState());

  Stream<CreateInviteScreenState> get state => _stateSubject;

  void _updateState(int? seconds, String? data) {
    final state = _stateSubject.value;
    _stateSubject.add(
      state.copyWith(
          seconds: seconds,
          data: data,
          loading: seconds == null && data == null),
    );
  }

  @override
  void init() {
    _connect();
  }

  @override
  void dispose() {
    _stateSubject.close();
    expire();
  }

  Future<CreateInviteScreenState> _connect() async {
    final completer = Completer<CreateInviteScreenState>();

    createInviteService.create((update) {
      if (update.state == CreateInviteState.expired) {
        navigator.replaceScreen(InviteExpiredScreen(
            viewModel: InviteExpiredViewModel(
                navigator: navigator,
                createInviteService: createInviteService,
                createConnectionService: createConnectionService)));
        completer.complete(CreateInviteScreenState());
      } else if (update.state == CreateInviteState.receivedUid) {
        navigator.replaceScreen(InviteAnsweredScreen(
            viewModel: InviteAnsweredScreenViewModel(
                navigator: navigator,
                invite: update.invite!,
                createInviteService: createInviteService,
                createConnectionService: createConnectionService)));
        completer.complete(CreateInviteScreenState());
      }

      _updateState(update.seconds, update.invite?.toJson());
    }, WeakReference(this));

    return completer.future;
  }
}
