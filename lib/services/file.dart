import 'package:flutter/services.dart';
import 'package:flutter_fd/flutter_fd.dart';

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
