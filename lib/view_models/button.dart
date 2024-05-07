import 'package:flutter/material.dart';

class ButtonViewModel {
  ButtonViewModel({this.title, required this.onPressed, this.icon});

  final String? title;
  final IconData? icon;
  final void Function() onPressed;
}
