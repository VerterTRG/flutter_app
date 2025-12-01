import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/modules/invoices/screens/invoices_screen.dart';
import 'routes.dart';

class Invoices implements AppModule {
 
  @override
  String get moduleId => 'invoices';

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Счета';

  @override
  IconData get icon => Icons.receipt;

  @override
  final FormManager forms = FormManager();

  @override
  final ActionManager actions = ActionManager();

  @override
  Map<String, AppModuleRoute> get routes => {
        InvoicesRoutes.list: AppModuleRoute(
            title: 'Список счетов',
            icon: Icons.receipt,
            builder: (tabId, args) =>
                InvoicesScreen(tabId: tabId, args: args)),
        InvoicesRoutes.create: AppModuleRoute(
            title: 'Создание счета',
            icon: Icons.edit_document,
            builder: (tabId, args) =>
                InvoicesScreen(tabId: tabId, args: args)),
        InvoicesRoutes.details: AppModuleRoute(
            title: 'Детали счета',
            icon: Icons.edit_document,
            builder: (tabId, args) =>
                InvoicesScreen(tabId: tabId, args: args)),
      };
}

class FormManager implements BaseFormsManager {
  @override
  AppAction get openDefault => list;
  // Ссылаемся на Routes.createInvoice.
  // Когда это выполнится, NavigationCubit пойдет в InvoicesModule.routes,
  // найдет там Routes.createInvoice и построить InvoiceFormScreen.
  final AppAction create = OpenTabAction(InvoicesRoutes.create);
  
  final AppAction list = OpenTabAction(InvoicesRoutes.list);
  
  final AppAction details = OpenTabAction(InvoicesRoutes.details);

}

class ActionManager implements BaseActionsManager {
  // Тут можно добавить бизнес-действия, специфичные для счетов.
}