import 'package:flutter_fd/flutter_fd.dart';
import 'package:p2p_copy_paste/services/clipboard.dart';

abstract class ClipboardFeature {
  void addClipboardServiceListener(
      Listener<void Function(WeakReference<IClipboardService>)> listener);

  void removeClipboardServiceListener(WeakReference<Context> context);
}
