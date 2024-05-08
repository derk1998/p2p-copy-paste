import 'dart:async';
import 'dart:developer';

import 'package:p2p_copy_paste/disposable.dart';
import 'package:rxdart/rxdart.dart';

class ConditionalObject<T extends Disposable> {
  ConditionalObject(this._creator, {this.dependencies});

  List<ConditionalObject<dynamic>>? dependencies;
  List<StreamSubscription<dynamic>>? _subscriptions;
  List<dynamic>? _objects;
  final T Function(List<dynamic>? dependencies) _creator;
  BehaviorSubject<T>? _subject;
  T? _object;

  bool _areDependenciesRetrieved() {
    return _objects!.length == dependencies!.length;
  }

  void _createObject() {
    _object = _creator(_objects);
    _subject!.add(_object!);
  }

  Stream<T> stream() {
    _subject ??= BehaviorSubject<T>(onCancel: () {
      log('Called onCancel()');
      _object!.dispose();
      _subject!.close();
      _subject = null;

      if (_subscriptions != null) {
        for (final subscription in _subscriptions!) {
          subscription.cancel();
        }
      }
    }, onListen: () {
      log('Called onListen()');
      if (dependencies != null) {
        _subscriptions = [];
        _objects = [];
        for (final dependency in dependencies!) {
          _subscriptions!.add(dependency.stream().listen((object) {
            _objects!.add(object);
            if (_areDependenciesRetrieved()) {
              _createObject();
            }
          }));
        }
      } else {
        _createObject();
      }
    });

    return _subject!;
  }
}
