import 'dart:async';
import 'dart:core';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';

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

class CreateInviteScreenViewModel
    extends DataScreenViewModel<CreateInviteScreenState> {
  CreateInviteScreenViewModel({required this.createInviteService});

  final WeakReference<ICreateInviteService> createInviteService;
  StreamSubscription<CreateInviteUpdate>? _createInviteUpdateSubscription;

  void _updateState(int? seconds, String? data) {
    final state = getLastPublishedValue();
    publish(
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
    super.init();

    _createInviteUpdateSubscription = createInviteService.target!
        .stream()
        .listen(_onCreateInviteStatusChanged);
    createInviteService.target!.create();
  }

  @override
  void dispose() {
    _createInviteUpdateSubscription?.cancel();
    super.dispose();
  }

  @override
  String getTitle() {
    return 'Create an invite';
  }

  @override
  CreateInviteScreenState getEmptyState() {
    return CreateInviteScreenState();
  }
}
