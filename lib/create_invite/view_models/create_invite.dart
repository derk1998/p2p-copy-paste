import 'dart:async';
import 'dart:core';

import 'package:p2p_copy_paste/lifetime.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
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
  CreateInviteScreenViewModel(
      {required this.navigator,
      required this.createInviteService,
      required this.createConnectionService,
      required this.clipboardService});

  final INavigator navigator;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  final IClipboardService clipboardService;
  final _stateSubject = BehaviorSubject<CreateInviteScreenState>.seeded(
      CreateInviteScreenState());
  StreamSubscription<CreateInviteUpdate>? _createInviteUpdateSubscription;

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

  void _onCreateInviteStatusChanged(CreateInviteUpdate createInviteUpdate) {
    _updateState(
        createInviteUpdate.seconds, createInviteUpdate.invite?.toJson());
  }

  @override
  void init() {
    _createInviteUpdateSubscription =
        createInviteService.stream().listen(_onCreateInviteStatusChanged);
    createInviteService.create();
  }

  @override
  void dispose() {
    _createInviteUpdateSubscription?.cancel();
    _stateSubject.close();
    expire();
  }

  @override
  String title() {
    return 'Create an invite';
  }
}
