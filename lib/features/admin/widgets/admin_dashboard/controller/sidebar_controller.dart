import 'package:flutter/material.dart';

class SidebarController {
  static final ValueNotifier<String> activeItem =
      ValueNotifier<String>('Dashboard');

  static void setActiveItem(String item) {
    activeItem.value = item;
  }
}
