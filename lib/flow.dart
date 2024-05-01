import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:rxdart/rxdart.dart';

abstract class Flow<S extends FlowState, ID> {
  final viewChangeSubject = BehaviorSubject<ScreenView>();
  final Map<ID, S> _states = {};
  late S _currentState;

  String name();

  @mustCallSuper
  void init() {
    log('${name()} init');
    _currentState.entry();
  }

  @mustCallSuper
  void dispose() {
    log('${name()} dispose');
  }

  void addState({required S state, required ID stateId}) {
    _states[stateId] = state;
  }

  void setInitialState(ID stateId) {
    _currentState = _states[stateId]!;
  }

  void setState(ID stateId) {
    _currentState.exit();
    _currentState = _states[stateId]!;
    _currentState.entry();
  }
}
