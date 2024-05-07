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
import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';
import 'package:rxdart/rxdart.dart';

enum _StateId {
  start,
  expired,
  receivedUid,
  declined,
  connect,
}

class CreateFlow extends Flow<FlowState, _StateId> {
  late StreamSubscription<CreateInviteUpdate> createInviteStatusSubscription;
  final ICreateInviteService createInviteService;
  Invite? invite;
  final _restartCondition = PublishSubject<bool>();
  StreamSubscription<bool>? _restartConditionSubscription;
  final CreateConnectionService createConnectionService;
  final void Function(TransceiveDataUseCase transceiveDataUseCase) onConnected;

  CreateFlow(
      {required this.createInviteService,
      required this.createConnectionService,
      required this.onConnected,
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
        state:
            FlowState(name: 'received uid', onEntry: _onEntryReceivedUidState),
        stateId: _StateId.receivedUid);
    addState(
        state: FlowState(name: 'declined', onEntry: _onEntryDeclinedState),
        stateId: _StateId.declined);

    addState(
        state: FlowState(name: 'connect', onEntry: _onEntryConnectState),
        stateId: _StateId.connect);

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

  void _onExitExpiredState() {
    _restartConditionSubscription?.cancel();
  }

  void _onEntryReceivedUidState() {
    final view = InviteAnsweredScreen(
        viewModel: InviteAnsweredScreenViewModel(
            invite: invite!,
            createInviteService: createInviteService,
            createConnectionService: createConnectionService));
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
      setState(_StateId.receivedUid);
    } else if (createInviteUpdate.state == CreateInviteState.accepted) {
      setState(_StateId.connect);
    } else if (createInviteUpdate.state == CreateInviteState.declined) {
      setState(_StateId.declined);
    }
  }

  void _onEntryConnectState() {
    createConnectionService.setOnConnectedListener(() {
      onConnected(createConnectionService);
      complete();
    });

    createConnectionService.createConnection(invite!.creator, invite!.joiner!);
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
