import 'package:p2p_copy_paste/context.dart';
import 'package:p2p_copy_paste/disposable.dart';

class ContextualObject extends Disposable {
  Context? _context;

  WeakReference<Context> getContext() {
    _context ??= Context();
    return WeakReference(_context!);
  }

  @override
  void dispose() {
    _context?.dispose();
    _context = null;
  }
}
