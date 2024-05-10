import 'dart:async';
import 'dart:developer';

import 'package:p2p_copy_paste/context.dart';
import 'package:p2p_copy_paste/contextual_object.dart';
import 'package:p2p_copy_paste/disposable.dart';
import 'package:p2p_copy_paste/listener.dart';
import 'package:p2p_copy_paste/weak_key.dart';
import 'package:rxdart/rxdart.dart';

class ConditionalObject<T extends Disposable> extends ContextualObject {
  ConditionalObject(this._creator, {this.dependencies});

  final Map<WeakKey<Context>, StreamSubscription<WeakReference<T>>> _listeners =
      {};

  List<ConditionalObject<dynamic>>? dependencies;

  List<WeakReference<dynamic>>? _objects;
  final T Function(List<dynamic>? dependencies) _creator;
  BehaviorSubject<WeakReference<T>>? _subject;
  T? _object;

  bool _areDependenciesRetrieved() {
    return _objects!.length == dependencies!.length;
  }

  void _createObject() {
    _object = _creator(_objects);
    _subject!.add(WeakReference(_object!));
  }

  void addListener(Listener<void Function(WeakReference<T>)> listener) {
    final context = listener.getContext();

    if (context.target != null) {
      context.target!.addExpiringListener(Listener((ctx) {
        removeListener(ctx);
      }, getContext()));
      _listeners[WeakKey(context)] = _stream(context).listen((object) {
        listener.lock()?.call(object);
      });
    }
  }

  void removeListener(WeakReference<Context> context) {
    log('Removing listener...');

    _listeners[WeakKey(context)]?.cancel();
    _listeners.remove(WeakKey(context));

    if (dependencies != null) {
      for (final dependency in dependencies!) {
        dependency.removeListener(context);
      }
    }
  }

  Stream<WeakReference<T>> _stream(WeakReference<Context> context) {
    _subject ??= BehaviorSubject<WeakReference<T>>(onCancel: () {
      log('Called onCancel()');
      _object!.dispose();
      _subject!.close();
      _subject = null;

      _objects?.clear();
      _object = null;
    }, onListen: () {
      log('Called onListen()');
      if (dependencies != null) {
        _objects = [];
        for (final dependency in dependencies!) {
          dependency.addListener(Listener((object) {
            _objects!.add(object);
            if (_areDependenciesRetrieved()) {
              _createObject();
            }
          }, context));
        }
      } else {
        _createObject();
      }
    });

    return _subject!;
  }
}
