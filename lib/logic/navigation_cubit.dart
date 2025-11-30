import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/models/tab_item.dart';
import 'package:flutter_app/modules/dashboard_module.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';


// 1. СОСТОЯНИЕ
class NavigationState {
  final List<TabItem> tabs;
  final int activeTabIndex;

  NavigationState({required this.tabs, required this.activeTabIndex});

  factory NavigationState.initial() {
    // При инициализации пытаемся загрузить Dashboard из реестра
    // Если реестр еще пуст (до main), создаем заглушку или ждем регистрации
    return NavigationState(tabs: [], activeTabIndex: -1);
  }

  NavigationState copyWith({List<TabItem>? tabs, int? activeTabIndex}) {
    return NavigationState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }
}

// 2. CUBIT
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.initial());

  /// Метод инициализации (вызываем в main после регистрации модулей)
  void init() {
    openTab(DashboardModule().moduleId);
  }

  void openTab(String moduleId, {String? sourceTabId, FormArguments? args}) {
    // 1. Ищем модуль, ответственный за этот тип таба
    final module = ModuleRegistry.get(moduleId);
    
    if (module == null) {
      debugPrint('🛑 ОШИБКА: Модуль для типа $moduleId не зарегистрирован!');
      return;
    }

    // 2. Генерация ID (Логика унифицирована)
    String tabId = moduleId;
    
    // Если это "создание" или "детали" - ID должен быть уникальным
    if (moduleId.startsWith('create') || sourceTabId != null) {
       // Пример: createClient_from_menu_173293023
       final timestamp = DateTime.now().millisecondsSinceEpoch;
       tabId = '${moduleId}_from_${sourceTabId ?? "root"}_$timestamp';
    } 
    
    // Если передан конкретный ID объекта (для просмотра деталей)
    final entityId = args?.getValue<String>('id');
    if (entityId != null) {
      tabId = '${moduleId}_$entityId';
    }

    // 3. Проверка на дубликаты (Если таб уже открыт - переключаемся)
    final existingIndex = state.tabs.indexWhere((t) => t.id == tabId);
    if (existingIndex != -1) {
      emit(state.copyWith(activeTabIndex: existingIndex));
      return;
    }

    // 4. Формирование заголовка
    // Берем дефолтный из модуля, но если в аргументах есть имя (для деталей) - берем его
    String title = module.title;
    final nameArg = args?.getValue<String>('name');
    if (nameArg != null) {
       title = nameArg;
    }

    // 5. Создание экрана (Делегируем модулю!)
    final screen = module.buildScreen(tabId, args);

    // 6. Обновление состояния
    final currentTabs = List<TabItem>.from(state.tabs);
    currentTabs.add(TabItem(
      id: tabId, 
      title: title, 
      icon: module.icon, 
      screen: screen
    ));

    emit(state.copyWith(
      tabs: currentTabs, 
      activeTabIndex: currentTabs.length - 1
    ));
  }

  void closeTab(int index) {
    // Защита от закрытия Дашборда
    if (state.tabs[index].id.contains('dashboard')) return;

    final currentTabs = List<TabItem>.from(state.tabs);
    currentTabs.removeAt(index);

    // Умный сдвиг индекса
    int newIndex = state.activeTabIndex;
    if (state.activeTabIndex >= index) {
      newIndex = (state.activeTabIndex - 1).clamp(0, currentTabs.length - 1);
    }

    emit(state.copyWith(tabs: currentTabs, activeTabIndex: newIndex));
  }

  void setActiveTab(int index) {
    emit(state.copyWith(activeTabIndex: index));
  }
}