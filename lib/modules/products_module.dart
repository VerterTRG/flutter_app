import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/screens/product_screen.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_app/core/routes.dart';

class ProductsModule implements AppModule {
  @override
  String get moduleId => Routes.products;

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Товары';

  @override
  IconData get icon => Icons.shopping_cart;

  @override
  Widget buildScreen(String tabId, FormArguments? args) {
    // Логика: если ID начинается с 'create', открываем форму, иначе список
    // Или просто возвращаем экран, который сам разберется
    return ProductsScreen(tabId: tabId, args: args);
  }
}