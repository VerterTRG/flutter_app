import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/modules/products/screens/product_screen.dart';

import 'routes.dart';


class Products implements AppModule {

  @override
  String get moduleId =>  'products';

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Товары';

  @override
  IconData get icon => Icons.shopping_cart;

  @override
  final FormsManager forms = FormsManager();

  @override
  final ActionsManager actions = ActionsManager();

// TODO: Реализовать экраны для товаров
  @override
  Map<String, AppModuleRoute> get routes => {
        ProductsRoutes.list: AppModuleRoute(
            title: 'Список товаров',
            icon: Icons.list,
            builder: (tabId, args) =>
                ProductsScreen(tabId: tabId, args: args)),
        ProductsRoutes.create: AppModuleRoute(
            title: 'Создание товара',
            icon: Icons.add,
            builder: (tabId, args) =>
                ProductsScreen(tabId: tabId, args: args)),
        ProductsRoutes.details: AppModuleRoute(
            title: 'Детали товара',
            icon: Icons.info,
            builder: (tabId, args) =>
                ProductsScreen(tabId: tabId, args: args)),
  };


  }



class FormsManager implements BaseFormsManager {
  @override
  AppAction get openDefault => list;
  
  final AppAction list = OpenTabAction(ProductsRoutes.list);
  final AppAction create = OpenTabAction(ProductsRoutes.create);
  final AppAction details = OpenTabAction(ProductsRoutes.details);
}

class ActionsManager implements BaseActionsManager {
  // Тут можно добавить действия для действий товаров, если нужно.
}