import 'package:flutter/material.dart';

// 1. Все возможные типы вкладок в приложении
enum TabType {
  dashboard,
  clients,
  addresses,
  products,
  invoices,
  
  // Динамические действия
  createClient,
  createAddress,
  clientDetails, // <-- Для примера открытия конкретного объекта
}

// 2. Статическая конфигурация (Иконки и Базовые названия)
class TabConfig {
  static final Map<TabType, IconData> icons = {
    TabType.dashboard: Icons.dashboard,
    TabType.clients: Icons.people,
    TabType.addresses: Icons.map,
    TabType.products: Icons.inventory,
    TabType.invoices: Icons.receipt,
    TabType.createClient: Icons.person_add,
    TabType.createAddress: Icons.add_location_alt,
    TabType.clientDetails: Icons.person,
  };

  static final Map<TabType, String> defaultTitles = {
    TabType.dashboard: 'Сводка',
    TabType.clients: 'Клиенты',
    TabType.addresses: 'Адреса',
    TabType.products: 'Товары',
    TabType.invoices: 'Инвойсы',
    TabType.createClient: 'Новый клиент',
    TabType.createAddress: 'Новый адрес',
    TabType.clientDetails: 'Клиент', // Будет перезаписано именем
  };

  // Хелпер для получения данных
  static IconData icon(TabType type) => icons[type] ?? Icons.help;
  static String title(TabType type) => defaultTitles[type] ?? 'Tab';
}
