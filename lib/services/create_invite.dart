import 'dart:async';

import 'package:p2p_copy_paste/config.dart';
import 'package:p2p_copy_paste/lifetime.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';

enum CreateInviteState { waiting, expired, receivedUid }

class CreateInviteUpdate {
  CreateInviteUpdate({required this.state, required this.seconds, this.invite});

  int seconds;
  CreateInviteState state;
  Invite? invite;
}

abstract class ICreateInviteService {
  Future<void> create(
      void Function(CreateInviteUpdate update) onCreateInviteUpdate,
      WeakReference<LifeTime> lifeTime);

  Future<bool> accept(Invite invite);
  Future<bool> decline(Invite invite);
}

class CreateInviteService extends ICreateInviteService {
  StreamSubscription<CreateInviteUpdate>? _createSubscription;
  StreamSubscription<Invite?>? _inviteSubscription;
  Invite? _invite;
  var _done = false;

  CreateInviteService(
      {required this.authenticationService, required this.inviteRepository});

  final IAuthenticationService authenticationService;
  final IInviteRepository inviteRepository;

  @override
  Future<void> create(
      void Function(CreateInviteUpdate update) onCreateInviteUpdate,
      WeakReference<LifeTime> lifeTime) async {
    _inviteSubscription?.cancel();
    _done = false;
    lifeTime.target?.setOnExpiringListener(_cancelSubscription);

    final ownUid = authenticationService.getUserId();
    await inviteRepository.addInvite(Invite(ownUid));

    _inviteSubscription =
        inviteRepository.snapshots(ownUid).listen(_onInviteUpdated);

    _createSubscription = Stream<CreateInviteUpdate>.periodic(
      const Duration(seconds: 1),
      _onPeriodicUpdate,
    ).listen((event) {
      onCreateInviteUpdate(event);
    });
  }

  @override
  Future<bool> accept(Invite invite) async {
    invite.accept();
    try {
      await inviteRepository.addInvite(invite);
    } catch (e) {
      return false;
    }

    return true;
  }

  @override
  Future<bool> decline(Invite invite) async {
    invite.decline();
    try {
      await inviteRepository.addInvite(invite);
    } catch (e) {
      return false;
    }

    return true;
  }

  void _cancelSubscription() {
    _createSubscription?.cancel();
  }

  CreateInviteUpdate _onPeriodicUpdate(int secondCount) {
    if (_done) {
      _cancelSubscription();
    }

    if (secondCount >= kInviteTimeoutInSeconds) {
      _done = true;
      return CreateInviteUpdate(seconds: 0, state: CreateInviteState.expired);
    }

    final currentSeconds = kInviteTimeoutInSeconds - secondCount;

    if (_invite?.joiner != null) {
      _done = true;
      return CreateInviteUpdate(
          seconds: currentSeconds,
          state: CreateInviteState.receivedUid,
          invite: _invite);
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
