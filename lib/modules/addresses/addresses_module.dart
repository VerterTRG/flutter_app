import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/screens/addresses_screen.dart';
import 'package:flutter_app/utils/common.dart';

class AddressesModule implements AppModule {
  @override
  String get moduleId => Routes.addresses; // Замена enum-у

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Адреса';

  @override
  IconData get icon => Icons.location_on;

  @override
  Widget buildScreen(String tabId, FormArguments? args) {
    // Логика: если ID начинается с 'create', открываем форму, иначе список
    // Или просто возвращаем экран, который сам разберется
    return AddressesScreen(tabId: tabId, args: args);
  }
}