import 'package:p2p_copy_paste/context.dart';

class Listener<T extends Object> {
  Listener(T listener, WeakReference<Context> context)
      : _listener = WeakReference(listener),
        _context = context;

  final WeakReference<T> _listener;
  final WeakReference<Context> _context;

  T? lock() {
    if (_context.target != null) {
      return _listener.target;
    }

    return null;
  }

  WeakReference<Context> getContext() {
    return _context;
  }
}
