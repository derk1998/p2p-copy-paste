import 'dart:async';

import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/create/screens/create_invite.dart';
import 'package:p2p_copy_paste/screen.dart';
import 'package:p2p_copy_paste/screens/horizontal_menu.dart';
import 'package:p2p_copy_paste/screens/restart.dart';
import 'package:p2p_copy_paste/create/view_models/create_invite.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';
import 'package:p2p_copy_paste/create/services/create_connection.dart';
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
  StreamSubscription<CreateInviteUpdate>? createInviteStatusSubscription;

  final Stream<WeakReference<ICreateInviteService>> createInviteStream;
  StreamSubscription<WeakReference<ICreateInviteService>>?
      _createInviteStreamSubscription;
  WeakReference<ICreateInviteService>? _createInviteService;

  Invite? invite;
  final _restartCondition = PublishSubject<bool>();
  StreamSubscription<bool>? _restartConditionSubscription;

  final Stream<WeakReference<ICreateConnectionService>> createConnectionStream;
  StreamSubscription<WeakReference<ICreateConnectionService>>?
      _createConnectionStreamSubscription;
  WeakReference<ICreateConnectionService>? _createConnectionService;

  CreateFlow(
      {required this.createInviteStream,
      required this.createConnectionStream,
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

    setInitialState(_StateId.loading);
  }

  void _onEntryStartState() {
    createInviteStatusSubscription = _createInviteService!.target!
        .stream()
        .listen(_onCreateInviteStatusChanged);

    final view = CreateInviteScreen(
        viewModel: CreateInviteScreenViewModel(
            createInviteService: _createInviteService!));
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
            _createConnectionService!.target!
                .setVisitor(invite!.creator, invite!.joiner!)
                .then(
              (value) {
                _createInviteService!.target!
                    .accept(CreatorInvite.fromInvite(invite!));
              },
            );
          }),
      ButtonViewModel(
          title: 'No',
          onPressed: () {
            _createInviteService!.target!
                .decline(CreatorInvite.fromInvite(invite!));
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
    _createInviteStreamSubscription = createInviteStream.listen((service) {
      _createInviteService = service;

      if (_createInviteService != null && _createConnectionService != null) {
        setState(_StateId.start);
      }
    });

    _createConnectionStreamSubscription =
        createConnectionStream.listen((service) {
      _createConnectionService = service;

      if (_createInviteService != null && _createConnectionService != null) {
        setState(_StateId.start);
      }
    });
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
    _createConnectionService!.target!.setOnConnectedListener(() {
      complete();
    });

    _createConnectionService!.target!
        .createConnection(invite!.creator, invite!.joiner!);
  }

  @override
  void dispose() {
    super.dispose();
    createInviteStatusSubscription?.cancel();
    _createInviteStreamSubscription!.cancel();
    _createConnectionStreamSubscription!.cancel();
    _restartCondition.close();
  }

  @override
  String name() {
    return 'Create flow';
  }
}
