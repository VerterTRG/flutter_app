import 'package:flutter/material.dart';
import 'package:flutter_app/utils/common.dart';


// Описание того, что умеет модуль
abstract class AppModule {
  // Уникальный ключ модуля ('clients', 'invoices')
  String get moduleId; 
  
  // Название для меню ('Клиенты')
  String get title;
  
  // Иконка для меню
  IconData get icon;

  // ! НОВОЕ: Должен ли модуль отображаться в боковом меню?
  // По умолчанию - true (большинство модулей там нужны)
  bool get isMenuItem => false;

  // Главная магия: Модуль сам строит свой экран
  Widget buildScreen(String tabId, FormArguments? args);
}

class ModuleRegistry {
  // Храним карту: "ключ" -> "Модуль"
  static final Map<String, AppModule> _modules = {};

  // Метод регистрации
  static void register(AppModule module) {
    _modules[module.moduleId] = module;
  }

  // Получить модуль по ключу
  static AppModule? get(String moduleId) => _modules[moduleId];
  
  // Получить все (для отрисовки меню)
  static List<AppModule> get all => _modules.values.toList();

  // ! НОВОЕ: Геттер для построения меню
  // Возвращает только те модули, у которых isMenuItem == true
  static List<AppModule> get menuItems => 
      _modules.values.where((m) => m.isMenuItem).toList();
}