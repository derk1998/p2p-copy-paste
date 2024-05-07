import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

class InviteAnsweredScreenViewModel extends ScreenViewModel {
  InviteAnsweredScreenViewModel(
      {required this.invite,
      required this.createInviteService,
      required this.createConnectionService}) {
    description =
        'Your invite has been answered. Did you accept the invite with code: ${invite.joiner!}?';
    acceptInviteButton =
        ButtonViewModel(title: 'Yes', onPressed: _onAcceptInviteButtonPressed);
    declineInviteButton =
        ButtonViewModel(title: 'No', onPressed: _onDeclineInviteButtonPressed);
  }

  final Invite invite;
  late String description;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  late ButtonViewModel acceptInviteButton;
  late ButtonViewModel declineInviteButton;

  void _onAcceptInviteButtonPressed() async {
    await createConnectionService.setVisitor(invite.creator, invite.joiner!);
    await createInviteService.accept(invite);
  }

  void _onDeclineInviteButtonPressed() {
    createInviteService.decline(invite);
  }

  @override
  void dispose() {}

  @override
  void init() {}

  @override
  String getTitle() {
    return 'Invite answered';
  }
}
