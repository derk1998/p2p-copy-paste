import 'package:flutter/material.dart';

class ButtonViewModel {
  ButtonViewModel({required this.title, required this.onPressed});

  final String title;
  final void Function() onPressed;
}

class IconButtonViewModel extends ButtonViewModel {
  IconButtonViewModel(
      {required super.title, required super.onPressed, required this.icon});

  final IconData icon;
}
