import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_webrtc/lifetime.dart';
import 'package:test_webrtc/models/invite.dart';
import 'package:test_webrtc/repositories/invite_repository.dart';
import 'package:test_webrtc/services/login.dart';

enum CreateInviteState { waiting, expired, receivedUid }

class CreateInviteUpdate {
  CreateInviteUpdate({required this.state, required this.seconds, this.invite});

  int seconds;
  CreateInviteState state;
  Invite? invite;
}

class CreateInviteService {
  CreateInviteService(this._ref);

  final Ref _ref;
  StreamSubscription<CreateInviteUpdate>? _createSubscription;
  StreamSubscription<Invite?>? _inviteSubscription;
  Invite? _invite;
  var _done = false;

  void create(void Function(CreateInviteUpdate update) onCreateInviteUpdate,
      WeakReference<LifeTime> lifeTime) async {
    _inviteSubscription?.cancel();
    _done = false;
    lifeTime.target?.setOnExpiringListener(_cancelSubscription);

    final ownUid = _ref.read(loginServiceProvider).getUserId();
    await _ref.read(invitesRepositoryProvider).addInvite(Invite(ownUid));

    _inviteSubscription = _ref
        .read(invitesRepositoryProvider)
        .snapshots(ownUid)
        .listen(_onInviteUpdated);

    _createSubscription = Stream<CreateInviteUpdate>.periodic(
      const Duration(seconds: 1),
      _onPeriodicUpdate,
    ).listen((event) {
      log(event.toString());
      onCreateInviteUpdate(event);
    });
  }

  void _cancelSubscription() {
    _createSubscription?.cancel();
    log('DONER');
  }

  CreateInviteUpdate _onPeriodicUpdate(int secondCount) {
    if (_done) {
      _cancelSubscription();
    }

    if (secondCount >= 30) {
      _done = true;
      return CreateInviteUpdate(seconds: 0, state: CreateInviteState.expired);
    }

    final currentSeconds = 30 - secondCount;

    if (_invite?.joiner != null) {
      _done = true;
      return CreateInviteUpdate(
          seconds: currentSeconds, state: CreateInviteState.receivedUid);
    }

    return CreateInviteUpdate(
        seconds: currentSeconds,
        state: CreateInviteState.waiting,
        invite: _invite);
  }

  void _onInviteUpdated(Invite? invite) {
    _invite = invite;
  }
}

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
CreateInviteService? _createInviteService;

final createInviteServiceProvider = Provider<CreateInviteService>((ref) {
  _createInviteService ??= CreateInviteService(ref);
  return _createInviteService!;
});
