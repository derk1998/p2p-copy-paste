import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/services/connection.dart';

abstract class JoinFeature {
  void addJoinInviteServiceListener(
      Listener<void Function(WeakReference<IJoinInviteService>)> listener);

  void removeJoinInviteServiceListener(WeakReference<Context> context);

  void addJoinConnectionServiceListener(
      Listener<void Function(WeakReference<IConnectionService>)> listener);

  void removeJoinConnectionServiceListener(WeakReference<Context> context);
}
