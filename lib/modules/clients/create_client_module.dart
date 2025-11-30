import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/screens/clients_screen.dart';
import 'package:flutter_app/utils/common.dart';

class CreateClientModule implements AppModule {
  @override
  String get moduleId => Routes.createClient;

  @override
  bool get isMenuItem => false; // Не показываем в меню

  @override
  String get title => 'Создание клиента';

  @override
  IconData get icon => Icons.person_add;

  @override
  Widget buildScreen(String tabId, FormArguments? args) {
    // TODO: Создать отдельный экран для создания клиента, если нужно
    return ClientsScreen(tabId: tabId, args: args);
  }
}