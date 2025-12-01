import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/models/tab_item.dart';
import 'package:flutter_app/modules/dashboard/routes.dart';
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
    openTab(DashboardRoutes.dashboard);
  }

  void openTab(String routeId, {String? sourceTabId, FormArguments? args}) {
    
    // 1. ЛОГИКА ФОРМИРОВАНИЯ ID (Твой вариант)
    String tabId = routeId;
    
    // Пытаемся найти ID конкретного объекта (для редактирования)
    final entityId = args?.getValue<String>('id');

    if (entityId != null) {
      // Приоритет 1: Уникальность по Сущности
      // Пример: clients/details/55
      tabId = '$routeId/$entityId';
      
    } else if (sourceTabId != null) {
      // Приоритет 2: Уникальность по Источнику (обычно для создания)
      // Пример: clients/create?from=invoices_tab_1
      tabId = '$routeId?from=$sourceTabId';
    }
    // Приоритет 3 (иначе): Глобальный синглтон
    // Пример: clients/list

    // 2. Проверяем, не открыт ли уже этот таб
    final existingIndex = state.tabs.indexWhere((t) => t.id == tabId);
    if (existingIndex != -1) {
      emit(state.copyWith(activeTabIndex: existingIndex));
      return;
    }

    // 3. ! ГЛАВНОЕ ИЗМЕНЕНИЕ: Строим экран через Реестр по Маршруту
    // Реестр сам найдет нужный модуль и нужную функцию в subRoutes
    final screen = AppModulesManager.buildScreen(routeId, tabId, args);

    if (screen == null) {
      debugPrint('🛑 ОШИБКА: Маршрут "$routeId" не найден ни в одном модуле!');
      return;
    }

    // 4. Получаем метаданные для таба
    // Получаем родителя и конфиг конкретного маршрута
    final parentModule = AppModulesManager.getModuleByRoute(routeId);
    final routeConfig = AppModulesManager.getRouteConfig(routeId);
    
    // Иконка: либо из конфигурации маршрута, либо из модуля, либо дефолтная
    final icon = routeConfig?.icon ?? parentModule?.icon ?? Icons.extension;
    // Заголовок: либо из аргументов, либо дефолтный из модуля, либо сам ID
    String title = args?.getValue<String>('title') ?? routeConfig?.title ?? parentModule?.title ?? 'Tab';

    // 5. Добавляем таб
    final currentTabs = List<TabItem>.from(state.tabs);
    currentTabs.add(TabItem(
      id: tabId, 
      title: title, 
      icon: icon,
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