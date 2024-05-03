import 'dart:core';

import 'package:p2p_copy_paste/view_models/button.dart';
import 'package:p2p_copy_paste/view_models/screen.dart';

class MenuScreenViewModel extends ScreenViewModel {
  MenuScreenViewModel(
      {required this.buttonViewModelList,
      required this.description,
      required this.title});

  final List<IconButtonViewModel> buttonViewModelList;
  final String title;
  final String description;

  @override
  void dispose() {}

  @override
  void init() {}

  @override
  String getTitle() {
    return title;
  }
}
