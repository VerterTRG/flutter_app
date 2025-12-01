import 'module_registry.dart';

/// Базовый класс для всех Фасадов (Clients, Invoices, etc.)
/// F - Тип менеджера форм (FormsManager)
/// A - Тип менеджера действий (ActionsManager)
abstract class BaseModuleClass<F, A> {
  
  // 1. Абстрактный геттер ID (каждый фасад должен сказать, кто он)
  String get moduleId;

  // 2. Абстрактные геттеры менеджеров (каждый фасад создает свои)
  F get forms;
  A get actions;

  // 3. ! ОБЩАЯ ЛОГИКА КОНФИГУРАЦИИ
  // Этот код теперь написан 1 раз и работает для всех
  AppModule get config {
    final module = AppModulesManager.getModuleById(moduleId);
    if (module == null) {
      throw Exception("🛑 ОШИБКА: Модуль '$moduleId' не зарегистрирован в main()!");
    }
    return module;
  }
}