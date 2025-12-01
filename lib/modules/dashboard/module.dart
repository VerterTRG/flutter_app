import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/modules/dashboard/routes.dart';
import 'package:flutter_app/modules/dashboard/screens/dashboard_screen.dart';

class Dashboard implements AppModule {

  static const String id = 'dashboard';

  @override
  String get moduleId => id; // Замена enum-у

  @override
  bool get isMenuItem => true;

  @override
  String get title => 'Dashboard';

  @override
  IconData get icon => Icons.dashboard;

  @override
  final FormsManager forms = FormsManager();

  @override
  final ActionsManager actions = ActionsManager();

  @override
  Map<String, AppModuleRoute> get routes => {
        DashboardRoutes.dashboard: AppModuleRoute(
            title: 'Dashboard',
            icon: Icons.dashboard,
            builder: (tabId, args) =>
                DashboardScreen(tabId: tabId)),
      };
}

class FormsManager implements BaseFormsManager {
  @override
  AppAction get openDefault => show;        
  // Действие: "Открыть Дашборд"
  // NavigationCubit по умолчанию обработает это как синглтон (откроет или переключит фокус),
  // так как мы не передаем sourceTabId.
  final AppAction show = OpenTabAction(DashboardRoutes.dashboard);
}

class ActionsManager implements BaseActionsManager {
  // Тут могут быть действия, специфичные для Дашборда.
  // Например, кнопка "Обновить все виджеты", которую можно вызвать из меню.
  
  // Пример:
  /*
  Future<void> refreshAll(BuildContext context) async {
    context.read<DashboardCubit>().refreshData();
  }
  */
}