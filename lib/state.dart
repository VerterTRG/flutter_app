import 'package:flutter/material.dart';
import 'package:flutter_app/models/client.dart';
import 'package:flutter_app/models/address.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/models/invoice.dart';
import 'package:flutter_app/models/tab_item.dart';
import 'package:flutter_app/screens/addresses_screen.dart';
import 'package:flutter_app/screens/clients_screen.dart';
import 'package:flutter_app/screens/dashboard_screen.dart';
import 'package:flutter_app/screens/invoices_screen.dart';
import 'package:flutter_app/screens/product_screen.dart';
import 'package:flutter_app/utils/common.dart';
import 'models/tab_config.dart'; 

class AppState extends ChangeNotifier {
  // === ДАННЫЕ ===
  final List<Client> clients = [Client('1', 'Иван Иванов'), Client('2', 'Петр Петров')];
  final List<Address> addresses = [];
  final List<Product> products = [];
  final List<Invoice> invoices = [];

  void addClient(String name) { clients.add(Client(DateTime.now().toString(), name)); notifyListeners(); }
  void addAddress(String clientId, String city, String? zip) { addresses.add(Address(DateTime.now().toString(), clientId, city, zip)); notifyListeners(); }
  void addProduct(String name, double price) { products.add(Product(DateTime.now().toString(), name, price)); notifyListeners(); }
  void addInvoice(String clientId, String addressId) { invoices.add(Invoice(DateTime.now().toString(), clientId, addressId)); notifyListeners(); }

  // === НАВИГАЦИЯ ===
  List<TabItem> tabs = [
    TabItem(
      id: TabType.dashboard.name, 
      title: TabConfig.title(TabType.dashboard), 
      icon: TabConfig.icon(TabType.dashboard), 
      screen: DashboardScreen(tabId: TabType.dashboard.name)
    )
  ];
  // int activeTabIndex = -1;
  int activeTabIndex = 0;

  // ГЛАВНЫЙ МЕТОД ОТКРЫТИЯ
  // type: Тип вкладки
  // sourceTabId: ID вкладки, откуда нажали (для предотвращения дублей создания)
  // entity: Объект данных (если открываем конкретного клиента для просмотра)
  void openTab(TabType type, {String? sourceTabId, Object? entity, FormArguments? args}) {
    
    // 1. ГЕНЕРАЦИЯ ID
    // Если это список (Dashboard, Clients) -> ID фиксированный (напр. "clients")
    // Если это создание -> ID зависит от источника (напр. "create_client_from_invoices")
    // Если это просмотр -> ID зависит от ID объекта (напр. "client_1")
    String id = type.name; 
    
    if (type == TabType.createClient || type == TabType.createAddress) {
       id = '${type.name}_from_${sourceTabId ?? "menu"}';
    } else if (type == TabType.clientDetails && entity is Client) {
       id = 'client_${entity.id}';
    }

    // 2. ПРОВЕРКА НА СУЩЕСТВОВАНИЕ
    final existingIndex = tabs.indexWhere((t) => t.id == id);
    if (existingIndex != -1) {
      activeTabIndex = existingIndex;
      notifyListeners();
      return;
    }

    // 3. ФОРМИРОВАНИЕ ЗАГОЛОВКА
    String title = TabConfig.title(type);
    if (type == TabType.clientDetails && entity is Client) {
      title = entity.name; // <--- ДИНАМИЧЕСКИЙ ЗАГОЛОВОК
    }

    // 4. СОЗДАНИЕ ЭКРАНА
Widget screen;
    switch (type) {
      case TabType.dashboard: screen = DashboardScreen(tabId: id); break;
      case TabType.clients: screen = ClientsScreen(tabId: id); break;
      case TabType.products: screen = ProductsScreen(tabId: id); break;
      case TabType.invoices: screen = InvoicesScreen(tabId: id); break;
      
      // ! ТЕПЕРЬ ВСЕ ФОРМЫ ПОЛУЧАЮТ ARGS ЕДИНООБРАЗНО
      case TabType.createClient: 
      case TabType.clientDetails:
        screen = ClientsScreen(tabId: id, args: args); 
        break;

      case TabType.addresses: // Список адресов
        screen = AddressesScreen(tabId: id); 
        break;

      case TabType.createAddress: // Форма создания
        screen = AddressesScreen(tabId: id, args: args); 
        break;
    }

    // 5. ДОБАВЛЕНИЕ
    tabs.add(TabItem(
      id: id,
      title: title,
      icon: TabConfig.icon(type),
      screen: screen,
    ));
    activeTabIndex = tabs.length - 1;
    notifyListeners();
  }

  void closeTab(int index) {
    // ЗАЩИТА: Не даем закрыть Dashboard (если вдруг UI позволит)
    if (tabs[index].id == TabType.dashboard.name) return;

    tabs.removeAt(index);
    if (tabs.isEmpty) {
      activeTabIndex = -1;
    } else if (activeTabIndex >= index) {
      activeTabIndex = (activeTabIndex - 1).clamp(0, tabs.length - 1);
    }
    notifyListeners();
  }

  void setActiveTab(int index) {
    activeTabIndex = index;
    notifyListeners();
  }
}