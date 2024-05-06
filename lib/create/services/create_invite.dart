import 'dart:async';
import 'dart:developer';

import 'package:p2p_copy_paste/config.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:rxdart/rxdart.dart';

enum CreateInviteState {
  waiting,
  expired,
  receivedUid,
  accepted,
  declined,
}

class CreateInviteUpdate {
  CreateInviteUpdate({required this.state, required this.seconds, this.invite});

  int seconds;
  CreateInviteState state;
  Invite? invite;
}

abstract class ICreateInviteService {
  Future<void> create();

  Future<void> accept(Invite invite);
  Future<void> decline(Invite invite);

  Stream<CreateInviteUpdate> stream();
  void dispose();
}

class CreateInviteService extends ICreateInviteService {
  StreamSubscription<Invite?>? _inviteSubscription;
  Invite? _invite;
  Timer? _timer;
  final statusUpdateSubject = PublishSubject<CreateInviteUpdate>();

  CreateInviteService(
      {required this.authenticationService, required this.inviteRepository});

  final IAuthenticationService authenticationService;
  final IInviteRepository inviteRepository;

  @override
  Future<void> create() async {
    final ownUid = authenticationService.getUserId();
    await inviteRepository.addInvite(Invite(ownUid));

    _inviteSubscription =
        inviteRepository.snapshots(ownUid).listen(_onInviteUpdated);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_onPeriodicUpdate(timer.tick)) {
        timer.cancel();
        _inviteSubscription?.cancel();
      }
    });
  }

  @override
  Future<void> accept(Invite invite) async {
    invite.accept();
    try {
      await inviteRepository.addInvite(invite);
      statusUpdateSubject.add(
          CreateInviteUpdate(seconds: 0, state: CreateInviteState.accepted));
    } catch (e) {
      statusUpdateSubject.add(
          CreateInviteUpdate(seconds: 0, state: CreateInviteState.expired));
    }
  }

  @override
  Future<void> decline(Invite invite) async {
    invite.decline();
    try {
      await inviteRepository.addInvite(invite);
    } catch (e) {
      //ignore
    }

    statusUpdateSubject
        .add(CreateInviteUpdate(seconds: 0, state: CreateInviteState.declined));
  }

  bool _onPeriodicUpdate(int secondCount) {
    if (secondCount >= kInviteTimeoutInSeconds) {
      statusUpdateSubject.add(
          CreateInviteUpdate(seconds: 0, state: CreateInviteState.expired));
      return true;
    }

    final currentSeconds = kInviteTimeoutInSeconds - secondCount;

    if (_invite?.joiner != null) {
      statusUpdateSubject.add(CreateInviteUpdate(
          seconds: currentSeconds,
          state: CreateInviteState.receivedUid,
          invite: _invite));
      return true;
    }

    statusUpdateSubject.add(CreateInviteUpdate(
        seconds: currentSeconds,
        state: CreateInviteState.waiting,
        invite: _invite));

    return false;
  }

  void _onInviteUpdated(Invite? invite) {
    _invite = invite;
  }

  @override
  Stream<CreateInviteUpdate> stream() {
    return statusUpdateSubject;
  }

  @override
  void dispose() {
    _inviteSubscription?.cancel();
    _timer?.cancel();
    statusUpdateSubject.close();
    log('Create invite service dispose');
  }
}
