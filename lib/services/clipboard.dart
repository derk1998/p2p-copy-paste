import 'package:flutter/services.dart' as services;

abstract class IClipboardService {
  Future<String?> get();
  void set(String data);
}

class ClipboardService implements IClipboardService {
  @override
  Future<String?> get() async {
    final data = await services.Clipboard.getData('text/plain');
    String? clipboardData;

    if (data != null) {
      clipboardData = data.text;
    }

    return clipboardData;
  }

  @override
  void set(String data) {
    services.Clipboard.setData(services.ClipboardData(text: data));
  }
}
