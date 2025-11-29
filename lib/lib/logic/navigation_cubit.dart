import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/models/tab_item.dart';
import 'package:flutter_app/screens/dashboard_screen.dart';
import 'package:flutter_app/screens/clients_screen.dart';
import 'package:flutter_app/screens/addresses_screen.dart';
import 'package:flutter_app/screens/invoices_screen.dart';
import 'package:flutter_app/screens/product_screen.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

// 1. СОСТОЯНИЕ (Что мы храним)
// Equatable нужен, чтобы Flutter понимал, изменились данные или нет
class NavigationState {
  final List<TabItem> tabs;
  final int activeTabIndex;

  NavigationState({required this.tabs, required this.activeTabIndex});

  // Начальное состояние: только Дашборд
  factory NavigationState.initial() {
    return NavigationState(
      tabs: [
        TabItem(
          id: TabType.dashboard.name,
          title: TabConfig.title(TabType.dashboard),
          icon: TabConfig.icon(TabType.dashboard),
          screen: DashboardScreen(tabId: TabType.dashboard.name),
        )
      ],
      activeTabIndex: 0,
    );
  }

  // Метод copyWith - стандарт для обновления неизменяемых (immutable) состояний
  NavigationState copyWith({List<TabItem>? tabs, int? activeIndex}) {
    return NavigationState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeIndex ?? this.activeTabIndex,
    );
  }
}

// 2. CUBIT (Логика действий)
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.initial());

  void openTab(TabType type, {String? sourceTabId, FormArguments? args}) {
    // В Cubit мы работаем с текущим состоянием через `state`
    final currentTabs = List<TabItem>.from(state.tabs);
    
    String id = type.name;
    if (type == TabType.createClient || type == TabType.createAddress) {
       id = '${type.name}_from_${sourceTabId ?? "menu"}_${DateTime.now().millisecondsSinceEpoch}';
    } else if (type == TabType.clientDetails) {
       // Тут логика чуть сложнее, упростим для примера
       final entityId = args?.getValue<String>('id');
       if (entityId != null) id = 'client_$entityId';
    }

    // Проверка на дубликат
    final existingIndex = currentTabs.indexWhere((t) => t.id == id);
    if (existingIndex != -1) {
      emit(state.copyWith(activeIndex: existingIndex));
      return;
    }

    // Формирование заголовка
    String title = TabConfig.title(type);
    if (args?.getValue<String>('name') != null && type == TabType.clientDetails) {
       title = args!.getValue<String>('name')!;
    }

    // Создание экрана
    Widget screen;
    switch (type) {
      case TabType.dashboard: screen = DashboardScreen(tabId: id); break;
      case TabType.clients: screen = ClientsScreen(tabId: id, args: args); break;
      case TabType.addresses: screen = AddressesScreen(tabId: id, args: args); break;
      case TabType.products: screen = ProductsScreen(tabId: id); break; // Заглушку надо сделать
      case TabType.invoices: screen = InvoicesScreen(tabId: id); break;
      case TabType.createClient: screen = ClientsScreen(tabId: id, args: args); break;
      case TabType.createAddress: screen = AddressesScreen(tabId: id, args: args); break;
      case TabType.clientDetails: screen = ClientsScreen(tabId: id, args: args); break;
    }

    // Добавляем и обновляем состояние
    currentTabs.add(TabItem(id: id, title: title, icon: TabConfig.icon(type), screen: screen));
    
    // emit - это аналог notifyListeners(), но он отправляет НОВЫЙ объект состояния
    emit(state.copyWith(tabs: currentTabs, activeIndex: currentTabs.length - 1));
  }

  void closeTab(int index) {
    if (state.tabs[index].id == TabType.dashboard.name) return;

    final currentTabs = List<TabItem>.from(state.tabs);
    currentTabs.removeAt(index);

    int newIndex = state.activeTabIndex;
    if (state.activeTabIndex >= index) {
      newIndex = (state.activeTabIndex - 1).clamp(0, currentTabs.length - 1);
    }

    emit(state.copyWith(tabs: currentTabs, activeIndex: newIndex));
  }

  void setActiveTab(int index) {
    emit(state.copyWith(activeIndex: index));
  }
}