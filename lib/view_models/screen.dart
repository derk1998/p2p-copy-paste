abstract class ScreenViewModel {
  String getTitle();
}

abstract class StatefulScreenViewModel extends ScreenViewModel {
  void init();
  void dispose();
}
