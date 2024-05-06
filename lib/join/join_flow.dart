import 'dart:async';

import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/join/screens/connect_dialog.dart';
import 'package:p2p_copy_paste/join/screens/join_connection.dart';
import 'package:p2p_copy_paste/join/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/join/view_models/connect_dialog.dart';
import 'package:p2p_copy_paste/join/view_models/join_connection.dart';
import 'package:p2p_copy_paste/join/view_models/scan_qr_code.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/join/services/join_connection.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:rxdart/rxdart.dart';

enum _StateId {
  start,
  retrieved,
  join,
  clipboard,
}

enum JoinViewType { camera, code }

class JoinFlow extends Flow<FlowState, _StateId> {
  final IJoinInviteService joinInviteService;
  final IJoinConnectionService joinConnectionService;
  final IClipboardService clipboardService;
  final INavigator navigator;
  Invite? _invite;
  final JoinViewType viewType;
  final _inviteRetrievedCondition = PublishSubject<Invite>();
  StreamSubscription<JoinInviteUpdate>? _joinInviteUpdateSubscription;
  StreamSubscription<Invite>? _inviteRetrievedConditionSubscription;
  final _restartCondition = PublishSubject<bool>();
  StreamSubscription<bool>? _restartConditionSubscription;

  JoinFlow(
      {required this.joinInviteService,
      required this.joinConnectionService,
      required this.navigator,
      required this.clipboardService,
      super.onCompleted,
      super.onCanceled,
      required this.viewType}) {
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
        state: FlowState(name: 'join', onEntry: _onEntryJoinState),
        stateId: _StateId.join);
    addState(
        state: FlowState(name: 'clipboard', onEntry: _onEntryClipboardState),
        stateId: _StateId.clipboard);

    setInitialState(_StateId.start);
  }

  void _onEntryStartState() {
    _inviteRetrievedConditionSubscription =
        _inviteRetrievedCondition.listen(_onInviteRetrievedConditionChanged);

    ScreenView? view;
    if (viewType == JoinViewType.camera) {
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

  void _onJoinInviteStatusChanged(JoinInviteUpdate joinInviteUpdate) {
    if (joinInviteUpdate.state == JoinInviteState.inviteAccepted) {
      setState(_StateId.join);
    }
  }

  void _onEntryJoinState() {
    joinConnectionService.setOnConnectedListener(() {
      setState(_StateId.clipboard);
    });

    //todo: the state needs to be captured so the state can be changed when connection fails
    joinConnectionService.joinConnection(_invite!.creator);
  }

  void _onEntryClipboardState() {
    joinConnectionService.setOnConnectionClosedListener(() {
      complete();
    });

    navigator.replaceScreen(ClipboardScreen(
      viewModel: ClipboardScreenViewModel(
        clipboardService: clipboardService,
        dataTransceiver: joinConnectionService,
      ),
    ));
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
    return 'Join flow';
  }
}
