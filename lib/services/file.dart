import 'package:flutter/services.dart';
import 'package:p2p_copy_paste/disposable.dart';

abstract class IFileService extends Disposable {
  Future<String> loadFile(String location);
}

class FileService implements IFileService {
  @override
  Future<String> loadFile(String location) {
    return rootBundle.loadString(location);
  }

  @override
  void dispose() {}
}
