import 'package:flutter_fd/flutter_fd.dart';

class BasicViewModel extends ScreenViewModel {
  BasicViewModel({required this.title, required this.description});

  final String description;
  final String title;

  @override
  String getTitle() {
    return title;
  }
}
