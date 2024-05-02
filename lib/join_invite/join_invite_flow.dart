import 'dart:async';

import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/join_invite/join_invite_service.dart';
import 'package:p2p_copy_paste/join_invite/screens/connect_dialog.dart';
import 'package:p2p_copy_paste/join_invite/screens/join_connection.dart';
import 'package:p2p_copy_paste/join_invite/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/join_invite/view_models/connect_dialog.dart';
import 'package:p2p_copy_paste/join_invite/view_models/join_connection.dart';
import 'package:p2p_copy_paste/join_invite/view_models/scan_qr_code.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:rxdart/rxdart.dart';

enum _StateId { start, retrieved, accepted }

enum JoinInviteViewType { camera, code }

class JoinInviteFlow extends Flow<FlowState, _StateId> {
  final IJoinInviteService joinInviteService;
  Invite? _invite;
  final JoinInviteViewType viewType;
  final _inviteRetrievedCondition = PublishSubject<Invite>();
  StreamSubscription<JoinInviteUpdate>? _joinInviteUpdateSubscription;
  StreamSubscription<Invite>? _inviteRetrievedConditionSubscription;
  final _restartCondition = PublishSubject<bool>();
  StreamSubscription<bool>? _restartConditionSubscription;
  void Function(Invite invite) onInviteAccepted;

  JoinInviteFlow(
      {required this.joinInviteService,
      super.onCompleted,
      super.onCanceled,
      required this.viewType,
      required this.onInviteAccepted}) {
    addState(
        state: FlowState(
            name: 'start',
            onEntry: _onEntryStartState,
            onExit: _onExitStartState),
        stateId: _StateId.start);
    addState(
        state: FlowState(
            name: 'retrieved',
            onEntry: _onEntryRetrievedState,
            onExit: _onExitRetrievedState),
        stateId: _StateId.retrieved);
    addState(
        state: FlowState(name: 'accepted', onEntry: _onEntryAcceptedState),
        stateId: _StateId.accepted);

    setInitialState(_StateId.start);
  }

  void _onEntryStartState() {
    _inviteRetrievedConditionSubscription =
        _inviteRetrievedCondition.listen(_onInviteRetrievedConditionChanged);

    ScreenView? view;
    if (viewType == JoinInviteViewType.camera) {
      view = ScanQRCodeScreen(
          viewModel: ScanQrCodeScreenViewModel(
              inviteRetrievedCondition: _inviteRetrievedCondition,
              joinInviteService: joinInviteService));
    } else {
      view = JoinConnectionScreen(
          viewModel: JoinConnectionScreenViewModel(
              joinInviteService: joinInviteService,
              inviteRetrievedCondition: _inviteRetrievedCondition));
    }

    viewChangeSubject.add(view);
  }

  void _onExitStartState() {
    _inviteRetrievedConditionSubscription?.cancel();
  }

  void _onInviteRetrievedConditionChanged(Invite invite) {
    _invite = invite;
    setState(_StateId.retrieved);
  }

  void _onEntryRetrievedState() {
    _restartConditionSubscription =
        _restartCondition.listen(_onRestartConditionChanged);

    final view = ConnectDialog(
      viewModel: ConnectDialogViewModel(
          invite: _invite!,
          joinInviteService: joinInviteService,
          restartCondition: _restartCondition),
    );

    viewChangeSubject.add(view);
  }

  void _onExitRetrievedState() {
    _restartConditionSubscription?.cancel();
  }

  void _onRestartConditionChanged(bool restart) {
    if (restart) {
      setState(_StateId.start);
    }
  }

  void _onEntryAcceptedState() {
    onInviteAccepted(_invite!);
    complete();
  }

  void _onJoinInviteStatusChanged(JoinInviteUpdate joinInviteUpdate) {
    if (joinInviteUpdate.state == JoinInviteState.inviteAccepted) {
      setState(_StateId.accepted);
    }
  }

  @override
  void init() {
    super.init();
    _joinInviteUpdateSubscription =
        joinInviteService.stream().listen(_onJoinInviteStatusChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _joinInviteUpdateSubscription?.cancel();
    joinInviteService.dispose();
    _inviteRetrievedCondition.close();
    _restartCondition.close();
  }

  @override
  String name() {
    return 'Join invite flow';
  }
}
