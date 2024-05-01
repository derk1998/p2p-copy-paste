import 'dart:developer';

class FlowState {
  FlowState({required this.name, this.onEntry, this.onExit});

  final String name;
  void Function()? onEntry;
  void Function()? onExit;

  void entry() {
    log('$name -> entry()');
    onEntry?.call();
  }

  void exit() {
    log('$name -> exit()');
    onExit?.call();
  }
}
