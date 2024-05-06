import 'package:p2p_copy_paste/flow.dart';
import 'package:p2p_copy_paste/screen_view.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';
import 'package:rxdart/rxdart.dart';

class FlowScreenState {
  FlowScreenState({required this.title, this.view});

  String title;
  ScreenView? view;
}

class FlowScreenViewModel extends ScreenViewModel {
  FlowScreenViewModel(this.flow);

  final Flow flow;

  final _stateSubject =
      BehaviorSubject<FlowScreenState>.seeded(FlowScreenState(title: ''));

  Stream<FlowScreenState> get state => _stateSubject;

  void _onViewChanged(ScreenView? view) {
    if (view == null) {
      _stateSubject.add(_stateSubject.value..view = view);
    } else {
      _stateSubject
          .add(FlowScreenState(title: view.viewModel.getTitle(), view: view));
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
