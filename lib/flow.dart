import 'dart:developer';

import 'package:fd_dart/fd_dart.dart';
import 'package:flutter/material.dart' as material;
import 'package:p2p_copy_paste/flow_state.dart';
import 'package:p2p_copy_paste/screen.dart';
import 'package:rxdart/rxdart.dart';

enum FlowStatus {
  canceled,
  completed,
  idle,
}

abstract class Flow<S extends FlowState, ID> extends ContextualObject {
  final viewChangeSubject = BehaviorSubject<Screen?>();
  final Map<ID, S> _states = {};
  late S _currentState;
  Future<void> Function()? onCompleted;
  Future<void> Function()? onCanceled;
  FlowStatus _status = FlowStatus.idle;

  Flow({this.onCompleted, this.onCanceled});

  String name();

  @material.mustCallSuper
  void init() {
    log('${name()} init');
    _currentState.entry();
  }

  @override
  void dispose() {
    _currentState.exit();

    if (_status == FlowStatus.idle) {
      cancel();
    }

    viewChangeSubject.close();
    log('${name()} dispose');
    super.dispose();
  }

  void addState({required S state, required ID stateId}) {
    _states[stateId] = state;
  }

  void loading() {
    viewChangeSubject.add(null);
  }

  void complete() {
    if (_status == FlowStatus.idle) {
      _status = FlowStatus.completed;
      _currentState.exit();
      log('${name()} is completed');
      onCompleted?.call();
    } else {
      log('${name()} cannot be completed because it is already completed or canceled');
    }
  }

  bool isCurrentState(ID state) {
    return _states[state] == _currentState;
  }

  void cancel() {
    if (_status == FlowStatus.idle) {
      _status = FlowStatus.canceled;
      _currentState.exit();
      log('${name()} is canceled');
      onCanceled?.call();
    } else {
      log('${name()} cannot be canceled because it is already completed or canceled');
    }
  }

  void onPopInvoked() {
    cancel();
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
