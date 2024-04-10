import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/services/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';

class InviteAnsweredScreenViewModel {
  InviteAnsweredScreenViewModel(
      {required this.invite,
      required this.navigator,
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
  final String title = 'Invite answered';
  late String description;
  final INavigator navigator;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  late ButtonViewModel acceptInviteButton;
  late ButtonViewModel declineInviteButton;

  void _onAcceptInviteButtonPressed() async {
    createConnectionService.setOnConnectedListener(() {
      navigator.pushScreen(
        ClipboardScreen(
            closeConnectionUseCase: createConnectionService,
            dataTransceiver: createConnectionService),
      );
    });
    await createConnectionService.startNewConnection();

    final result = await createInviteService.accept(invite);
    if (!result) {
      createConnectionService.close();
    }
  }

  void _onDeclineInviteButtonPressed() {
    createInviteService.decline(invite);
    navigator.popScreen();
  }
}
