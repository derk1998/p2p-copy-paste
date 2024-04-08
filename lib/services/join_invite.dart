import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
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

class JoinInviteService {
  JoinInviteService(this._ref);

  final Ref _ref;
  StreamSubscription<Invite?>? _subscription;

  Future<void> join(
      Invite invite,
      void Function(InviteStatus inviteStatus)
          onInviteStatusChangedListener) async {
    try {
      _subscription?.cancel();

      final retrievedInvite = (await _ref
          .read(invitesRepositoryProvider)
          .getInvite(invite.creator));

      retrievedInvite.joiner =
          GetIt.I.get<IAuthenticationService>().getUserId();
      _ref.read(invitesRepositoryProvider).updateInvite(retrievedInvite);
      onInviteStatusChangedListener.call(InviteStatus.inviteSent);
      _subscription = _ref
          .read(invitesRepositoryProvider)
          .snapshots(retrievedInvite.creator)
          .timeout(
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

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
JoinInviteService? _joinInviteService;

final joinInviteServiceProvider = Provider<JoinInviteService>((ref) {
  _joinInviteService ??= JoinInviteService(ref);
  return _joinInviteService!;
});
