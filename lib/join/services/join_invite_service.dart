import 'dart:async';
import 'dart:developer';

import 'package:p2p_copy_paste/config.dart';
import 'package:p2p_copy_paste/disposable.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';
import 'package:rxdart/rxdart.dart';

enum JoinInviteState {
  inviteSent,
  inviteAccepted,
  inviteDeclined,
  inviteTimeout,
  inviteError,
}

class JoinInviteUpdate {
  JoinInviteUpdate({required this.state, required this.invite});

  final JoinInviteState state;
  final Invite invite;
}

abstract class IJoinInviteService extends Disposable {
  Future<void> join(Invite invite);
  Stream<JoinInviteUpdate> stream();
  Future<void> accept(JoinerInvite invite);
}

class JoinInviteService implements IJoinInviteService {
  JoinInviteService(
      {required this.inviteRepository, required this.authenticationService});

  StreamSubscription<Invite?>? _subscription;
  final WeakReference<IInviteRepository> inviteRepository;
  final WeakReference<IAuthenticationService> authenticationService;
  final statusUpdateSubject = PublishSubject<JoinInviteUpdate>();

  @override
  Future<void> accept(JoinerInvite invite) async {
    invite.accept();
    await inviteRepository.target!.updateInvite(invite);
  }

  @override
  Future<void> join(Invite invite) async {
    try {
      _subscription?.cancel();

      final retrievedInvite =
          (await inviteRepository.target!.getInvite(invite.creator));

      retrievedInvite.joiner = authenticationService.target!.getUserId();
      inviteRepository.target!.updateInvite(retrievedInvite);

      statusUpdateSubject.add(JoinInviteUpdate(
          state: JoinInviteState.inviteSent, invite: retrievedInvite));

      _subscription =
          inviteRepository.target!.snapshots(retrievedInvite.creator).timeout(
        const Duration(seconds: kInviteTimeoutInSeconds),
        onTimeout: (sink) {
          _subscription?.cancel();
          statusUpdateSubject.add(JoinInviteUpdate(
              state: JoinInviteState.inviteTimeout, invite: retrievedInvite));
        },
      ).listen((inv) async {
        if (inv?.acceptedByCreator != null) {
          _subscription!.cancel();

          statusUpdateSubject.add(JoinInviteUpdate(
              state: inv!.acceptedByCreator!
                  ? JoinInviteState.inviteAccepted
                  : JoinInviteState.inviteDeclined,
              invite: inv));
        }
      }, onError: (e) {
        _subscription!.cancel();
        statusUpdateSubject.add(JoinInviteUpdate(
            state: JoinInviteState.inviteError, invite: retrievedInvite));
      });
    } catch (e) {
      _subscription?.cancel();
      statusUpdateSubject.add(
          JoinInviteUpdate(state: JoinInviteState.inviteError, invite: invite));
    }
  }

  @override
  Stream<JoinInviteUpdate> stream() {
    return statusUpdateSubject;
  }

  @override
  void dispose() {
    statusUpdateSubject.close();
    log('Join invite service dispose');
  }
}
