import 'package:flutter/material.dart' as material;
import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/screen.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class FlowScreenState {
  FlowScreenState({required this.title, this.view});

  String title;
  material.Widget? view;
}

class FlowScreenViewModel extends StatefulScreenViewModel {
  FlowScreenViewModel(this.flow);

  final Flow flow;

  final _stateSubject =
      BehaviorSubject<FlowScreenState>.seeded(FlowScreenState(title: ''));

  Stream<FlowScreenState> get state => _stateSubject;

  void _onViewChanged(Screen? screen) {
    if (screen == null) {
      _stateSubject.add(_stateSubject.value..view = null);
    } else {
      _stateSubject.add(FlowScreenState(
          title: screen.viewModel.getTitle(), view: screen.view));
    }
  }

  @override
  void init() {
    flow.init();
    flow.viewChangeSubject.listen(_onViewChanged);
  }

  void onPopInvoked() {
    flow.onPopInvoked();
  }

  @override
  void dispose() {
    flow.dispose();
    _stateSubject.close();
  }

  @override
  String getTitle() {
    return '';
  }
}
