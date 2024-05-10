import 'dart:async';
import 'dart:developer';

import 'package:p2p_copy_paste/disposable.dart';
import 'package:p2p_copy_paste/listener.dart';
import 'package:p2p_copy_paste/weak_key.dart';
import 'package:rxdart/rxdart.dart';

class Context extends Disposable {
  PublishSubject<WeakReference<Context>>? _subject;
  final Map<WeakKey<Context>, StreamSubscription<WeakReference<Context>>>
      _listeners = {};

  void addExpiringListener(
      Listener<void Function(WeakReference<Context>)> listener) {
    _subject ??= PublishSubject();

    final context = listener.getContext();
    if (context.target != null) {
      _listeners[WeakKey(context)] = _subject!.listen((object) {
        listener.lock()?.call(object);
      });
    }
  }

  void removeExpiringListener(WeakReference<Context> context) {
    _listeners[WeakKey(context)]?.cancel();
    _listeners.remove(WeakKey(context));
  }

  @override
  void dispose() {
    log('Call expiring listeners...');
    _subject!.add(WeakReference(this));
    _subject!.close();
    _subject = null;
    _listeners.clear();
  }
}
