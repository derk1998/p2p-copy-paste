import 'dart:async';

import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/navigation_manager.dart';
import 'package:p2p_copy_paste/create_invite/screens/create_invite.dart';
import 'package:p2p_copy_paste/create_invite/screens/invite_answered.dart';
import 'package:p2p_copy_paste/create_invite/screens/invite_expired.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';
import 'package:p2p_copy_paste/services/create_connection.dart';
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart';
import 'package:p2p_copy_paste/create_invite/view_models/create_invite.dart';
import 'package:p2p_copy_paste/create_invite/view_models/invite_answered.dart';
import 'package:p2p_copy_paste/create_invite/view_models/invite_expired.dart';

enum _StateId { start, expired, answered, end }

class CreateInviteFlow extends Flow<FlowState, _StateId> {
  late StreamSubscription<CreateInviteUpdate> createInviteStatusSubscription;
  final INavigator navigator;
  final ICreateInviteService createInviteService;
  final ICreateConnectionService createConnectionService;
  final IClipboardService clipboardService;
  Invite? invite;

  //kind of a lot of dependencies but we will fix it later
  CreateInviteFlow(
      {required this.navigator,
      required this.createInviteService,
      required this.createConnectionService,
      required this.clipboardService}) {
    addState(
        state: FlowState(name: 'start', onEntry: _onEntryStartState),
        stateId: _StateId.start);
    addState(
        state: FlowState(name: 'expired', onEntry: _onEntryExpiredState),
        stateId: _StateId.expired);
    addState(
        state: FlowState(name: 'answered', onEntry: _onEntryAnsweredState),
        stateId: _StateId.answered);
    addState(
        state: FlowState(name: 'end', onEntry: _onEntryEndState),
        stateId: _StateId.end);

    setInitialState(_StateId.start);
  }

  void _onEntryStartState() {
    final view = CreateInviteScreen(
        viewModel: CreateInviteScreenViewModel(
      navigator: navigator,
      createInviteService: createInviteService,
      createConnectionService: createConnectionService,
      clipboardService: clipboardService,
    ));
    viewChangeSubject.add(view);
  }

  void _onEntryExpiredState() {
    final view = InviteExpiredScreen(
        viewModel: InviteExpiredViewModel(
            navigator: navigator,
            createInviteService: createInviteService,
            createConnectionService: createConnectionService,
            clipboardService: clipboardService));
    viewChangeSubject.add(view);
  }

  void _onEntryAnsweredState() {
    final view = InviteAnsweredScreen(
        viewModel: InviteAnsweredScreenViewModel(
            navigator: navigator,
            invite: invite!,
            createInviteService: createInviteService,
            createConnectionService: createConnectionService,
            clipboardService: clipboardService));
    viewChangeSubject.add(view);
  }

  void _onEntryEndState() {
    //todo: check what to do here
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
    }

    //todo: when to end
  }

  @override
  void dispose() {
    super.dispose();
    createInviteStatusSubscription.cancel();
    createInviteService.dispose();
    viewChangeSubject.close();
  }

  @override
  String name() {
    return 'Create invite flow';
  }
}
