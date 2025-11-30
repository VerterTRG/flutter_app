import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/screens/clients_screen.dart';
import 'package:flutter_app/utils/common.dart';

class ClientsModule implements AppModule {
  @override
  String get moduleId => Routes.clients;

  @override
  bool get isMenuItem =>  true;

  @override
  String get title => 'Клиенты';

  @override
  IconData get icon => Icons.people;

  @override
  Widget buildScreen(String tabId, FormArguments? args) {
    // Логика: если ID начинается с 'create', открываем форму, иначе список
    // Или просто возвращаем экран, который сам разберется
    return ClientsScreen(tabId: tabId, args: args);
  }
}