import 'package:fd_dart/fd_dart.dart';
import 'package:flutter/services.dart';

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
