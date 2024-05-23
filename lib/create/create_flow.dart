import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/create/services/create_invite.dart';
import 'package:p2p_copy_paste/features/clipboard.dart';
import 'package:p2p_copy_paste/features/create.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/create/screens/create_invite.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/screens/horizontal_menu.dart';
import 'package:p2p_copy_paste/screens/restart.dart';
import 'package:p2p_copy_paste/create/view_models/create_invite.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/view_models/menu.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';
import 'package:rxdart/rxdart.dart';

enum _StateId {
  retrieveServices,
  start,
  expired,
  receivedUid,
  declined,
  connect,
  loading,
  clipboard,
}

class CreateFlow extends Flow<_StateId> {
  StreamSubscription<CreateInviteUpdate>? createInviteStatusSubscription;

  WeakReference<ICreateInviteService>? _createInviteService;
  WeakReference<IConnectionService>? _createConnectionService;
  ClipboardFeature clipboardFeature;
  CreateFeature createFeature;
  INavigator navigator;

  Invite? invite;
  final _restartCondition = PublishSubject<bool>();
  StreamSubscription<bool>? _restartConditionSubscription;

  CreateFlow(
      {required this.createFeature,
      required this.clipboardFeature,
      required this.navigator,
      super.onCompleted,
      super.onCanceled}) {
    addState(
        state: FlowState(
            name: 'retrieve services', onEntry: _onEntryRetrieveServicesState),
        stateId: _StateId.retrieveServices);
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
    addState(
        state: FlowState(
            name: 'clipboard',
            onEntry: _onEntryClipboardState,
            onPop: _onPopClipboard),
        stateId: _StateId.clipboard);

    setInitialState(_StateId.retrieveServices);
  }

  void _onPopClipboard() {
    navigator.pushDialog(
      CancelConfirmDialog(
        viewModel: CancelConfirmViewModel(
          title: 'Are you sure?',
          description: 'The connection will be lost',
          onCancelButtonPressed: () {
            navigator.popScreen();
          },
          onConfirmButtonPressed: () {
            navigator.popScreen();
            _createConnectionService!.target!.close();
          },
        ),
      ),
    );
  }

  void _onEntryRetrieveServicesState() {
    loading();

    createFeature
        .addCreateConnectionServiceListener(Listener((createConnectionService) {
      _createConnectionService = createConnectionService;
      _goToStartIfReady();
    }, this));

    createFeature
        .addCreateInviteServiceListener(Listener((createInviteService) {
      _createInviteService = createInviteService;
      _goToStartIfReady();
    }, this));
  }

  void _goToStartIfReady() {
    if (_createConnectionService != null && _createInviteService != null) {
      setState(_StateId.start);
    }
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
      setState(_StateId.clipboard);
    });

    _createConnectionService!.target!.connect(invite!.creator, invite!.joiner!);
  }

  void _onEntryClipboardState() {
    loading();
    _createConnectionService!.target!.setOnDisconnectedListener(() {
      complete();
    });

    clipboardFeature.addClipboardServiceListener(Listener((service) {
      final view = ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            connectionService: _createConnectionService!,
            clipboardService: service),
      );

      viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
    }, this));
  }

  @override
  void dispose() {
    super.dispose();
    createInviteStatusSubscription?.cancel();
    _restartCondition.close();
  }

  @override
  String name() {
    return 'Create flow';
  }
}
