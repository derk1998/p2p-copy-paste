import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/services/connection.dart';

abstract class CreateFeature {
  void addCreateInviteServiceListener(
      Listener<void Function(WeakReference<ICreateInviteService>)> listener);

  void removeCreateInviteServiceListener(WeakReference<Context> context);

  void addCreateConnectionServiceListener(
      Listener<void Function(WeakReference<IConnectionService>)> listener);

  void removeCreateConnectionServiceListener(WeakReference<Context> context);
}
