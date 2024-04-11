import 'dart:async';

import 'package:p2p_copy_paste/config.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/authentication.dart';

enum InviteStatus {
  inviteSent,
  inviteAccepted,
  inviteDeclined,
  inviteTimeout,
  inviteError,
}

abstract class IJoinInviteService {
  Future<void> join(Invite invite,
      void Function(InviteStatus inviteStatus) onInviteStatusChangedListener);
}

class JoinInviteService implements IJoinInviteService {
  JoinInviteService(
      {required this.inviteRepository, required this.authenticationService});

  StreamSubscription<Invite?>? _subscription;
  final IInviteRepository inviteRepository;
  final IAuthenticationService authenticationService;

  @override
  Future<void> join(
      Invite invite,
      void Function(InviteStatus inviteStatus)
          onInviteStatusChangedListener) async {
    try {
      _subscription?.cancel();

      final retrievedInvite =
          (await inviteRepository.getInvite(invite.creator));

      retrievedInvite.joiner = authenticationService.getUserId();
      inviteRepository.updateInvite(retrievedInvite);
      onInviteStatusChangedListener.call(InviteStatus.inviteSent);
      _subscription =
          inviteRepository.snapshots(retrievedInvite.creator).timeout(
        const Duration(seconds: kInviteTimeoutInSeconds),
        onTimeout: (sink) {
          _subscription!.cancel();
          onInviteStatusChangedListener.call(InviteStatus.inviteTimeout);
        },
      ).listen((invite) {
        if (invite?.accepted != null) {
          _subscription!.cancel();
          onInviteStatusChangedListener.call(invite!.accepted!
              ? InviteStatus.inviteAccepted
              : InviteStatus.inviteDeclined);
        }
      }, onError: (e) {
        _subscription!.cancel();
        onInviteStatusChangedListener.call(InviteStatus.inviteError);
      });
    } catch (e) {
      _subscription?.cancel();
      onInviteStatusChangedListener.call(InviteStatus.inviteError);
    }
  }
}
