import 'package:flutter/services.dart';

abstract class IFileService {
  Future<String> loadFile(String location);
}

class FileService implements IFileService {
  @override
  Future<String> loadFile(String location) {
    return rootBundle.loadString(location);
  }
}
