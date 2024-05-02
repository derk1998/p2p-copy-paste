import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

class InviteAnsweredScreenViewModel extends ScreenViewModel {
  InviteAnsweredScreenViewModel(
      {required this.invite,
      required this.navigator,
      required this.createInviteService,
      required this.createConnectionService,
      required this.clipboardService}) {
    description =
        'Your invite has been answered. Did you accept the invite with code: ${invite.joiner!}?';
    acceptInviteButton =
        ButtonViewModel(title: 'Yes', onPressed: _onAcceptInviteButtonPressed);
    declineInviteButton =
        ButtonViewModel(title: 'No', onPressed: _onDeclineInviteButtonPressed);
  }

  final Invite invite;
  late String description;
  final INavigator navigator;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  final IClipboardService clipboardService;
  late ButtonViewModel acceptInviteButton;
  late ButtonViewModel declineInviteButton;

  void _onAcceptInviteButtonPressed() async {
    createInviteService.accept(invite);
  }

  void _onDeclineInviteButtonPressed() {
    createInviteService.decline(invite);
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void init() {
    // TODO: implement init
  }

  @override
  String title() {
    return 'Invite answered';
  }
}
