import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'routes.dart';
import 'screens/company_list_screen.dart';
import 'screens/company_details_screen.dart';

class CompanyModule implements AppModule {
  // Singleton instance
  static final CompanyModule _instance = CompanyModule._internal();
  factory CompanyModule() => _instance;
  CompanyModule._internal();

  @override
  String get moduleId => 'company';

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Компании';

  @override
  IconData get icon => Icons.business;

  @override
  final FormsManager forms = FormsManager();

  @override
  final ActionsManager actions = ActionsManager();

  @override
  Map<String, AppModuleRoute> get routes => {
    CompanyRoutes.list: AppModuleRoute(
      title: 'Список компаний',
      icon: Icons.list,
      builder: (tabId, args) => CompanyListScreen(tabId: tabId, args: args)
    ),
    CompanyRoutes.create: AppModuleRoute(
      title: 'Создание компании',
      icon: Icons.add_business,
      builder: (tabId, args) => CompanyDetailsScreen(tabId: tabId, args: args)
    ),
    CompanyRoutes.details: AppModuleRoute(
      title: 'Детали компании',
      icon: Icons.business_center,
      builder: (tabId, args) => CompanyDetailsScreen(tabId: tabId, args: args)
    ),
  };
}

class FormsManager implements BaseFormsManager {
  @override
  AppAction get openDefault => list;

  final AppAction list = OpenTabAction(CompanyRoutes.list);
  final AppAction create = OpenTabAction(CompanyRoutes.create);
  final AppAction edit = OpenTabAction(CompanyRoutes.details);
}

class ActionsManager implements BaseActionsManager {
  // Add company specific actions here if needed
}
