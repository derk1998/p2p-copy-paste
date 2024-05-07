import 'package:p2p_copy_paste/view_models/screen.dart';

class BasicViewModel extends ScreenViewModel {
  BasicViewModel({required this.title, required this.description});

  final String description;
  final String title;

  @override
  String getTitle() {
    return title;
  }
}
