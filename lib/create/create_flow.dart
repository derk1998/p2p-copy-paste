import 'dart:async';

import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/create/screens/create_invite.dart';
import 'package:p2p_copy_paste/create/screens/invite_answered.dart';
import 'package:p2p_copy_paste/create/screens/invite_expired.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/create/view_models/create_invite.dart';
import 'package:p2p_copy_paste/create/view_models/invite_answered.dart';
import 'package:p2p_copy_paste/create/view_models/invite_expired.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';
import 'package:rxdart/rxdart.dart';

enum _StateId {
  start,
  expired,
  answered,
  declined,
  connect,
  clipboard,
  dialog,
}

class CreateFlow extends Flow<FlowState, _StateId> {
  late StreamSubscription<CreateInviteUpdate> createInviteStatusSubscription;
  final ICreateInviteService createInviteService;
  final INavigator navigator;
  final IClipboardService clipboardService;
  Invite? invite;
  final _restartCondition = PublishSubject<bool>();
  StreamSubscription<bool>? _restartConditionSubscription;
  final CreateConnectionService createConnectionService;

  CreateFlow(
      {required this.createInviteService,
      required this.navigator,
      required this.createConnectionService,
      required this.clipboardService,
      super.onCompleted,
      super.onCanceled}) {
    addState(
        state: FlowState(name: 'start', onEntry: _onEntryStartState),
        stateId: _StateId.start);
    addState(
        state: FlowState(
            name: 'expired',
            onEntry: _onEntryExpiredState,
            onExit: _onExitExpiredState),
        stateId: _StateId.expired);
    addState(
        state: FlowState(name: 'answered', onEntry: _onEntryAnsweredState),
        stateId: _StateId.answered);
    addState(
        state: FlowState(name: 'declined', onEntry: _onEntryDeclinedState),
        stateId: _StateId.declined);

    addState(
        state: FlowState(name: 'connect', onEntry: _onEntryConnectState),
        stateId: _StateId.connect);
    addState(
        state: FlowState(
            name: 'clipboard',
            onEntry: _onEntryClipboardState,
            onExit: _onExitClipboardState),
        stateId: _StateId.clipboard);
    addState(
        state: FlowState(name: 'dialog', onEntry: _onEntryDialogState),
        stateId: _StateId.dialog);

    setInitialState(_StateId.start);
  }

  void _onEntryStartState() {
    final view = CreateInviteScreen(
        viewModel: CreateInviteScreenViewModel(
            createInviteService: createInviteService));
    viewChangeSubject.add(view);
  }

  void _onEntryExpiredState() {
    _restartConditionSubscription =
        _restartCondition.listen(_onRestartConditionChanged);

    final view = InviteExpiredScreen(
        viewModel: InviteExpiredViewModel(
            restartCondition: _restartCondition,
            createInviteService: createInviteService));
    viewChangeSubject.add(view);
  }

  void _onRestartConditionChanged(bool restart) {
    if (restart) {
      setState(_StateId.start);
    }
  }

  @override
  void onPopInvoked() {
    if (isCurrentState(_StateId.clipboard)) {
      setState(_StateId.dialog);
    } else {
      cancel();
    }
  }

  void _onExitExpiredState() {
    _restartConditionSubscription?.cancel();
  }

  void _onEntryAnsweredState() {
    final view = InviteAnsweredScreen(
        viewModel: InviteAnsweredScreenViewModel(
            invite: invite!, createInviteService: createInviteService));
    viewChangeSubject.add(view);
  }

  void _onEntryDeclinedState() {
    cancel();
  }

  @override
  void init() {
    super.init();
    createInviteStatusSubscription =
        createInviteService.stream().listen(_onCreateInviteStatusChanged);
  }

  //Transitions
  void _onCreateInviteStatusChanged(CreateInviteUpdate createInviteUpdate) {
    if (createInviteUpdate.state == CreateInviteState.expired) {
      setState(_StateId.expired);
    } else if (createInviteUpdate.state == CreateInviteState.receivedUid) {
      invite = createInviteUpdate.invite;
      setState(_StateId.answered);
    } else if (createInviteUpdate.state == CreateInviteState.accepted) {
      setState(_StateId.connect);
    } else if (createInviteUpdate.state == CreateInviteState.declined) {
      setState(_StateId.declined);
    }
  }

  void _onEntryConnectState() {
    createConnectionService.setOnConnectedListener(() {
      setState(_StateId.clipboard);
    });

    createConnectionService.startNewConnection();
  }

  void _onEntryClipboardState() {
    createConnectionService.setOnConnectionClosedListener(() {
      complete();
    });

    navigator.replaceScreen(
      ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            dataTransceiver: createConnectionService,
            clipboardService: clipboardService),
      ),
    );
  }

  void _onExitClipboardState() {
    createConnectionService.dispose();
  }

  void _onEntryDialogState() {
    navigator.pushDialog(
      CancelConfirmDialog(
        viewModel: CancelConfirmViewModel(
          title: 'Are you sure?',
          description: 'The connection will be lost',
          onCancelButtonPressed: () {
            navigator.popScreen();
          },
          onConfirmButtonPressed: () {
            createConnectionService.close();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    createInviteStatusSubscription.cancel();
    createInviteService.dispose();
    _restartCondition.close();
  }

  @override
  String name() {
    return 'Create flow';
  }
}
