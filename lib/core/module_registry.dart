import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/utils/common.dart';

typedef ScreenBuilder = Widget Function(String tabId, FormArguments? args);

class AppModuleRoute {
  final String title;       // "Новый клиент"
  final IconData? icon;     // Иконка (Icons.add). Если null - возьмем у родителя.
  final ScreenBuilder builder;

  const AppModuleRoute({
    required this.title,
    required this.builder,
    this.icon,
  });
}

abstract class BaseFormsManager {
  // Мы можем обязать всех иметь "Главное действие", чтобы меню работало предсказуемо
  AppAction get openDefault; 
}

// Базовый интерфейс для менеджеров действий
abstract class BaseActionsManager {}
// Описание того, что умеет модуль
abstract class AppModule {
  // Уникальный ключ модуля ('clients', 'invoices')
  String get moduleId; 
  // Название для меню ('Клиенты')
  String get title;
  // Иконка для меню
  IconData get icon;
  // Должен ли модуль отображаться в боковом меню?
  bool get isMenuItem => false;

  Map<String, AppModuleRoute> get routes;

  // === ДОСТУП К ФУНКЦИЯМ (API) ===
  // Модуль обязан предоставить доступ к своим менеджерам
  BaseFormsManager get forms;
  BaseActionsManager get actions;
}

class AppModulesManager {
  // Список модулей для меню
  static final List<AppModule> _menuModules = [];
  // Карта для поиска по ID модуля ('clients' -> ClientsModule)
  static final Map<String, AppModule> _modulesById = {};
  // Карта "Маршрут -> Модуль-владелец"
  static final Map<String, AppModule> _routeOwners = {};

  // Карта "Маршрут -> Конфигурация маршрута"
  static final Map<String, AppModuleRoute> _routeConfigs = {};

  static void register(AppModule module) {
    // ... регистрация для меню ...
    if (module.isMenuItem) {
      _menuModules.add(module);
    }
    // Заполняем карту модулей по ID
    _modulesById[module.moduleId] = module;
    // Заполняем карту владельцев
    // Если модуль ClientsModule имеет subRoutes ['clients/create', 'clients/list'],
    // мы записываем:
    // 'clients/create' -> ClientsModule
    // 'clients/list'   -> ClientsModule
    module.routes.forEach((route, config) {
      _routeOwners[route] = module;
      _routeConfigs[route] = config;
    });
  }

  // Метод, который использует Кубит в пункте 3
  static Widget? buildScreen(String routeId, String tabId, FormArguments? args) {
    // 1. Кто владелец этого маршрута?
    final module = _routeOwners[routeId];
    if (module == null) return null;

    final config = _routeConfigs[routeId];
    return config?.builder(tabId, args);
  }

  // Helpers:
  static AppModule? getModuleByRoute(String routeId) => _routeOwners[routeId];
  static List<AppModule> get menuModules => _menuModules;
  static AppModule? getModuleById(String moduleId) => _modulesById[moduleId];
  static AppModuleRoute? getRouteConfig(String routeId) => _routeConfigs[routeId];
}