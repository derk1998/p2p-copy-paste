import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/lifetime.dart';
import 'package:test_webrtc/screens/invite_answered.dart';
import 'package:test_webrtc/screens/invite_expired.dart';
import 'package:test_webrtc/services/create_invite.dart';
import 'package:test_webrtc/view_models/invite_answered.dart';
import 'package:test_webrtc/view_models/invite_expired.dart';

class CreateInviteScreenData {
  CreateInviteScreenData({this.data, this.seconds});

  int? seconds;
  String? data;
}

class CreateInviteScreenViewModel extends AutoDisposeFamilyAsyncNotifier<
    CreateInviteScreenData, NavigatorState> with LifeTime {
  final String title = 'Create an invite';

  @override
  FutureOr<CreateInviteScreenData> build(NavigatorState arg) {
    ref.onDispose(() {
      expire();
    });
    return _connect(arg);
  }

  Future<CreateInviteScreenData> _connect(NavigatorState navigator) async {
    state = const AsyncLoading();
    final completer = Completer<CreateInviteScreenData>();

    ref.read(createInviteServiceProvider).create((update) {
      if (update.state == CreateInviteState.expired) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => InviteExpiredScreen(
                viewModel: InviteExpiredViewModel(navigator: navigator)),
          ),
        );
        completer.complete(CreateInviteScreenData());
      } else if (update.state == CreateInviteState.receivedUid) {
        navigator.pushReplacement(MaterialPageRoute(
            builder: (context) => InviteAnsweredScreen(
                viewModel: InviteAnsweredScreenViewModel(
                    navigator: navigator, invite: update.invite!, ref: ref))));
        completer.complete(CreateInviteScreenData());
      }

      state = AsyncData(CreateInviteScreenData(
          seconds: update.seconds, data: update.invite?.toJson()));
    }, WeakReference(this));

    return completer.future;
  }
}

final createInviteScreenViewModelProvider =
    AutoDisposeAsyncNotifierProviderFamily<CreateInviteScreenViewModel,
        CreateInviteScreenData, NavigatorState>(() {
  return CreateInviteScreenViewModel();
});
