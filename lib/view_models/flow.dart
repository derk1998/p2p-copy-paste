import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class FlowScreenState {
  FlowScreenState({required this.title, this.view});

  String title;
  ScreenView? view;
}

class FlowScreenViewModel extends StatefulScreenViewModel {
  FlowScreenViewModel(this.flow);

  final Flow flow;

  final _stateSubject =
      BehaviorSubject<FlowScreenState>.seeded(FlowScreenState(title: ''));

  Stream<FlowScreenState> get state => _stateSubject;

  void _onViewChanged(ScreenView view) {
    _stateSubject
        .add(FlowScreenState(title: view.viewModel.title(), view: view));
  }

  @override
  void init() {
    flow.init();
    flow.viewChangeSubject.listen(_onViewChanged);
  }

  @override
  void dispose() {
    flow.dispose();
    _stateSubject.close();
  }

  @override
  String title() {
    return '';
  }
}
