import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/modules/addresses/screens/addresses_screen.dart';

import 'routes.dart';

class Addresses implements AppModule {

  @override
  String moduleId = 'addresses'; // Замена enum-у

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Адреса';

  @override
  IconData get icon => Icons.business;

  @override
  final FormsManager forms = FormsManager();

  @override
  final ActionsManager actions = ActionsManager();

    // TODO: Реализовать экран создания адреса
  @override
  Map<String, AppModuleRoute> get routes => {
        AddressesRoutes.list: AppModuleRoute(
            title: 'Список адресов',
            icon: Icons.business,
            builder: (tabId, args) =>
                AddressesScreen(tabId: tabId, args: args)),
        AddressesRoutes.create: AppModuleRoute(
            title: 'Создание адреса',
            icon: Icons.add_business_outlined,
            builder: (tabId, args) =>
                AddressesScreen(tabId: tabId, args: args)),
        AddressesRoutes.details: AppModuleRoute(
            title: 'Детали адреса',
            icon: Icons.store_mall_directory_outlined,
            builder: (tabId, args) =>
                AddressesScreen(tabId: tabId, args: args)),
      };
  }


  class FormsManager implements BaseFormsManager {

  @override
  AppAction get openDefault => list;

  final AppAction list = OpenTabAction(AddressesRoutes.list);

  final AppAction create = OpenTabAction(AddressesRoutes.create);

  final AppAction details = OpenTabAction(AddressesRoutes.details);
}

class ActionsManager implements BaseActionsManager {
  // Тут можно добавить бизнес-действия, специфичные для адресов.
}