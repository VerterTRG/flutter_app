import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/screens/addresses_screen.dart';
import 'package:flutter_app/utils/common.dart';

class CreateAddressModule implements AppModule {
  @override
  String get moduleId => Routes.createAddress; // Замена enum-у

  @override
  bool get isMenuItem => false;

  @override
  String get title => 'Создание адреса';

  @override
  IconData get icon => Icons.add_location;

  @override
  Widget buildScreen(String tabId, FormArguments? args) {
    // TODO: Реализовать экран создания адреса
    return AddressesScreen(tabId: tabId, args: args);
  }
}