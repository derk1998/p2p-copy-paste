import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/repositories/invite_repository.dart';
import 'package:p2p_copy_paste/services/login.dart';

class JoinInviteService {
  JoinInviteService(this._ref);

  final Ref _ref;
  StreamSubscription<Invite?>? _subscription;

  Future<bool> join(Invite invite) async {
    final completer = Completer<bool>();
    try {
      _subscription?.cancel();

      final retrievedInvite = (await _ref
          .read(invitesRepositoryProvider)
          .getInvite(invite.creator));

      retrievedInvite.joiner = _ref.read(loginServiceProvider).getUserId();
      _ref.read(invitesRepositoryProvider).updateInvite(retrievedInvite);
      _subscription = _ref
          .read(invitesRepositoryProvider)
          .snapshots(retrievedInvite.creator)
          .timeout(
        const Duration(seconds: kInviteTimeoutInSeconds),
        onTimeout: (sink) {
          _subscription!.cancel();
          completer.complete(false);
        },
      ).listen((invite) {
        if (invite?.accepted != null) {
          _subscription!.cancel();
          completer.complete(invite!.accepted!);
        }
      }, onError: (e) {
        _subscription!.cancel();
        completer.complete(false);
      });
    } catch (e) {
      completer.complete(false);
    }

    return completer.future;
  }
}

//Currently, there is no good way to detect when to clean up this
//service. So now once it is constructed, it will live forever.
JoinInviteService? _joinInviteService;

final joinInviteServiceProvider = Provider<JoinInviteService>((ref) {
  _joinInviteService ??= JoinInviteService(ref);
  return _joinInviteService!;
});
