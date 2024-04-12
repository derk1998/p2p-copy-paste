import 'package:flutter/material.dart';

abstract class INavigator {
  void replaceScreen(Widget view);
  void pushScreen(Widget view);
  GlobalKey<NavigatorState> getNavigatorKey();
  void goToHome();
  void popScreen();
  void pushDialog(Widget view);
}

class NavigationManager extends INavigator {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void pushScreen(Widget view) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => view),
    );
  }

  @override
  void replaceScreen(Widget view) {
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => view),
    );
  }

  @override
  GlobalKey<NavigatorState> getNavigatorKey() {
    return _navigatorKey;
  }

  @override
  void goToHome() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  void popScreen() {
    _navigatorKey.currentState?.pop();
  }

  @override
  void pushDialog(Widget view) {
    if (_navigatorKey.currentContext != null) {
      showDialog(
          context: _navigatorKey.currentContext!, builder: (context) => view);
    }
  }
}
