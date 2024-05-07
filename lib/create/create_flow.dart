import 'dart:async';

import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/create/screens/create_invite.dart';
import 'package:p2p_copy_paste/screen.dart';
import 'package:p2p_copy_paste/screens/horizontal_menu.dart';
import 'package:p2p_copy_paste/screens/restart.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/create/view_models/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';
import 'package:p2p_copy_paste/create/services/create_connection.dart';
import 'package:p2p_copy_paste/use_cases/transceive_data.dart';
import 'package:rxdart/rxdart.dart';

enum _StateId {
  start,
  expired,
  receivedUid,
  declined,
  connect,
  loading,
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
    addState(
        state: FlowState(name: 'loading', onEntry: _onEntryLoadingState),
        stateId: _StateId.loading);

    setInitialState(_StateId.start);
  }

  void _onEntryStartState() {
    final view = CreateInviteScreen(
        viewModel: CreateInviteScreenViewModel(
            createInviteService: createInviteService));
    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onEntryExpiredState() {
    _restartConditionSubscription =
        _restartCondition.listen(_onRestartConditionChanged);

    final view = RestartScreen(
        viewModel: RestartViewModel(
            title: 'Invite has expired',
            restartCondition: _restartCondition,
            description:
                'Your invite has expired. Do you want to create a new one?'));
    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onRestartConditionChanged(bool restart) {
    if (restart) {
      setState(_StateId.start);
    }
  }

  void _onEntryLoadingState() {
    loading();
  }

  void _onExitExpiredState() {
    _restartConditionSubscription?.cancel();
  }

  void _onEntryReceivedUidState() {
    final buttonViewModelList = [
      ButtonViewModel(
          title: 'Yes',
          onPressed: () {
            createConnectionService
                .setVisitor(invite!.creator, invite!.joiner!)
                .then(
              (value) {
                createInviteService.accept(CreatorInvite.fromInvite(invite!));
              },
            );
          }),
      ButtonViewModel(
          title: 'No',
          onPressed: () {
            createInviteService.decline(CreatorInvite.fromInvite(invite!));
          })
    ];

    final view = HorizontalMenuScreen(
        viewModel: MenuScreenViewModel(
      title: 'Invite answered',
      description:
          'Your invite has been answered. Did you accept the invite with code: ${invite!.joiner!}?',
      buttonViewModelList: buttonViewModelList,
    ));

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
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
    invite = createInviteUpdate.invite;

    switch (createInviteUpdate.state) {
      case CreateInviteState.expired:
        setState(_StateId.expired);
        break;
      case CreateInviteState.receivedUid:
        setState(_StateId.receivedUid);
        break;
      case CreateInviteState.accepted:
        setState(_StateId.connect);
        break;
      case CreateInviteState.declined:
        setState(_StateId.declined);
        break;
      case CreateInviteState.accepting:
        setState(_StateId.loading);
        break;
      case CreateInviteState.waiting:
        break;
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
