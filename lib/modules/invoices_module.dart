import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/screens/invoices_screen.dart';
import 'package:flutter_app/utils/common.dart';

class InvoicesModule implements AppModule {
  @override
  String get moduleId => Routes.invoices;

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Счета';

  @override
  IconData get icon => Icons.receipt;

  @override
  Widget buildScreen(String tabId, FormArguments? args) {
    return InvoicesScreen(tabId: tabId, args: args);
  }
}