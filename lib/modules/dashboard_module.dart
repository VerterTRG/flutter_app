import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/screens/dashboard_screen.dart';
import 'package:flutter_app/utils/common.dart';

class DashboardModule implements AppModule {
  @override
  String get moduleId => Routes.dashboard; // Замена enum-у

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Dashboard';

  @override
  IconData get icon => Icons.dashboard;

  @override
  Widget buildScreen(String tabId, FormArguments? args) {
    // Логика: если ID начинается с 'create', открываем форму, иначе список
    // Или просто возвращаем экран, который сам разберется
    return DashboardScreen(tabId: tabId);
  }
}