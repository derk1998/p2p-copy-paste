import 'dart:async';

import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/features/clipboard.dart';
import 'package:p2p_copy_paste/features/join.dart';
import 'package:p2p_copy_paste/screens/clipboard.dart';
import 'package:p2p_copy_paste/screens/restart.dart';
import 'package:p2p_copy_paste/services/connection.dart';
import 'package:p2p_copy_paste/view_models/cancel_confirm.dart';
import 'package:p2p_copy_paste/view_models/clipboard.dart';
import 'package:p2p_copy_paste/view_models/restart.dart';
import 'package:p2p_copy_paste/join/services/join_invite_service.dart';
import 'package:p2p_copy_paste/screens/centered_description.dart';
import 'package:p2p_copy_paste/join/screens/join_connection.dart';
import 'package:p2p_copy_paste/join/screens/scan_qr_code.dart';
import 'package:p2p_copy_paste/view_models/basic.dart';
import 'package:p2p_copy_paste/join/view_models/join_connection.dart';
import 'package:p2p_copy_paste/join/view_models/scan_qr_code.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/widgets/cancel_confirm_dialog.dart';
import 'package:rxdart/rxdart.dart';

enum _StateId {
  retrieveServices,
  start,
  retrieved,
  error,
  timeout,
  declined,
  sent,
  addVisitor,
  join,
  clipboard,
}

enum JoinViewType { camera, code }

class JoinFlow extends Flow<_StateId> {
  WeakReference<IJoinInviteService>? _joinInviteService;
  WeakReference<IConnectionService>? _joinConnectionService;
  ClipboardFeature clipboardFeature;
  JoinFeature joinFeature;
  INavigator navigator;

  Invite? _invite;
  final JoinViewType viewType;
  final _inviteRetrievedCondition = PublishSubject<Invite>();
  StreamSubscription<JoinInviteUpdate>? _joinInviteUpdateSubscription;
  StreamSubscription<Invite>? _inviteRetrievedConditionSubscription;
  final _restartCondition = PublishSubject<bool>();
  StreamSubscription<bool>? _restartConditionSubscription;

  JoinFlow(
      {required this.joinFeature,
      required this.clipboardFeature,
      required this.navigator,
      super.onCompleted,
      super.onCanceled,
      required this.viewType}) {
    addState(
        state: FlowState(
            name: 'retrieveServices', onEntry: _onEntryRetrieveServicesState),
        stateId: _StateId.retrieveServices);
    addState(
        state: FlowState(
            name: 'start',
            onEntry: _onEntryStartState,
            onExit: _onExitStartState),
        stateId: _StateId.start);
    addState(
        state: FlowState(name: 'retrieved', onEntry: _onEntryRetrievedState),
        stateId: _StateId.retrieved);
    addState(
        state: FlowState(name: 'error', onEntry: _onEntryErrorState),
        stateId: _StateId.error);
    addState(
        state: FlowState(name: 'timeout', onEntry: _onEntryTimeoutState),
        stateId: _StateId.timeout);
    addState(
        state: FlowState(name: 'declined', onEntry: _onEntryDeclinedState),
        stateId: _StateId.declined);
    addState(
        state: FlowState(name: 'sent', onEntry: _onEntrySentState),
        stateId: _StateId.sent);
    addState(
        state: FlowState(name: 'add visitor', onEntry: _onEntryAddVisitorState),
        stateId: _StateId.addVisitor);
    addState(
        state: FlowState(name: 'join', onEntry: _onEntryJoinState),
        stateId: _StateId.join);
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
            _joinConnectionService!.target!.close();
          },
        ),
      ),
    );
  }

  void _onEntryRetrieveServicesState() {
    loading();

    joinFeature
        .addJoinConnectionServiceListener(Listener((joinConnectionService) {
      _joinConnectionService = joinConnectionService;
      _goToStartIfReady();
    }, this));

    joinFeature.addJoinInviteServiceListener(Listener((joinInviteService) {
      _joinInviteService = joinInviteService;
      _goToStartIfReady();
    }, this));
  }

  void _goToStartIfReady() {
    if (_joinConnectionService != null && _joinInviteService != null) {
      setState(_StateId.start);
    }
  }

  void _onEntryStartState() {
    _joinInviteUpdateSubscription =
        _joinInviteService!.target!.stream().listen(_onJoinInviteStatusChanged);
    _inviteRetrievedConditionSubscription =
        _inviteRetrievedCondition.listen(_onInviteRetrievedConditionChanged);

    StatefulScreenView? view;
    if (viewType == JoinViewType.camera) {
      view = ScanQRCodeScreen(
          viewModel: ScanQrCodeScreenViewModel(
              inviteRetrievedCondition: _inviteRetrievedCondition,
              joinInviteService: _joinInviteService!.target!));
    } else {
      view = JoinConnectionScreen(
          viewModel: JoinConnectionScreenViewModel(
              inviteRetrievedCondition: _inviteRetrievedCondition));
    }

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onExitStartState() {
    _inviteRetrievedConditionSubscription?.cancel();
  }

  void _onInviteRetrievedConditionChanged(Invite invite) {
    _invite = invite;
    setState(_StateId.retrieved);
  }

  void _onEntryRetrievedState() {
    loading();
    _joinInviteService!.target!.join(_invite!);
  }

  void _onEntryErrorState() {
    final view = RestartScreen(
        viewModel: RestartViewModel(
            title: 'Invalid invite',
            restartCondition: _restartCondition,
            description:
                'The invite is invalid or outdated. Please try again.'));

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onEntryTimeoutState() {
    final view = RestartScreen(
        viewModel: RestartViewModel(
            title: 'Invite has expired',
            restartCondition: _restartCondition,
            description: 'The invite is expired. Please try again.'));

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onEntryDeclinedState() {
    final view = RestartScreen(
        viewModel: RestartViewModel(
            title: 'Invite is declined',
            restartCondition: _restartCondition,
            description:
                'The invite is declined by the other device. Please try again.'));

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onEntrySentState() {
    final view = CenteredDescriptionScreen(
      viewModel: BasicViewModel(
        title: 'Verify',
        description:
            'Verify if the following code is displayed on the other device: ${_invite!.joiner}',
      ),
    );

    viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
  }

  void _onRestartConditionChanged(bool restart) {
    if (restart) {
      setState(_StateId.start);
    }
  }

  void _onJoinInviteStatusChanged(JoinInviteUpdate joinInviteUpdate) {
    _invite = joinInviteUpdate.invite;

    switch (joinInviteUpdate.state) {
      case JoinInviteState.inviteAccepted:
        setState(_StateId.addVisitor);
        break;
      case JoinInviteState.inviteError:
        setState(_StateId.error);
        break;
      case JoinInviteState.inviteTimeout:
        setState(_StateId.timeout);
        break;
      case JoinInviteState.inviteDeclined:
        setState(_StateId.declined);
        break;
      case JoinInviteState.inviteSent:
        setState(_StateId.sent);
        break;
    }
  }

  void _onEntryJoinState() {
    loading();
    _joinConnectionService!.target!.setOnConnectedListener(() {
      setState(_StateId.clipboard);
    });

    //todo: the state needs to be captured so the state can be changed when connection fails
    _joinConnectionService!.target!.connect(_invite!.joiner!, _invite!.creator);
  }

  void _onEntryAddVisitorState() {
    loading();
    _joinConnectionService!.target!
        .setVisitor(_invite!.joiner!, _invite!.creator)
        .then((value) {
      _joinInviteService!.target!
          .accept(JoinerInvite.fromInvite(_invite!))
          .then((value) {
        setState(_StateId.join);
      });
    });
  }

  void _onEntryClipboardState() {
    loading();
    _joinConnectionService!.target!.setOnDisconnectedListener(() {
      complete();
    });

    clipboardFeature.addClipboardServiceListener(Listener((service) {
      final view = ClipboardScreen(
        viewModel: ClipboardScreenViewModel(
            connectionService: _joinConnectionService!,
            clipboardService: service),
      );

      viewChangeSubject.add(Screen(view: view, viewModel: view.viewModel));
    }, this));
  }

  @override
  void init() {
    super.init();

    _restartConditionSubscription =
        _restartCondition.listen(_onRestartConditionChanged);
  }

  @override
  void dispose() {
    _joinInviteUpdateSubscription?.cancel();
    _inviteRetrievedCondition.close();
    _restartConditionSubscription?.cancel();
    _restartCondition.close();
    super.dispose();
  }

  @override
  String name() {
    return 'Join flow';
  }
}
