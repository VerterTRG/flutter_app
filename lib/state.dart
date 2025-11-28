import 'package:flutter/material.dart';
import 'models.dart';
import 'screens.dart'; // Чтобы создавать виджеты

// Модель одной открытой вкладки
class TabItem {
  final String id;
  final String title;
  final Widget screen;
  final IconData icon;

  TabItem({required this.id, required this.title, required this.screen, required this.icon});
}

class AppState extends ChangeNotifier {
  // === ДАННЫЕ ===
  final List<Client> clients = [Client('1', 'Иван Иванов'), Client('2', 'Петр Петров')];
  final List<Address> addresses = [];
  final List<Product> products = [];
  final List<Invoice> invoices = [];

  void addClient(String name) { clients.add(Client(DateTime.now().toString(), name)); notifyListeners(); }
  void addAddress(String clientId, String city) { addresses.add(Address(DateTime.now().toString(), clientId, city)); notifyListeners(); }
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
  void openTab(TabType type, {String? sourceTabId, Object? entity}) {
    
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
      case TabType.addresses: screen = AddressesScreen(tabId: id); break;
      case TabType.products: screen = ProductsScreen(tabId: id); break;
      case TabType.invoices: screen = InvoicesScreen(tabId: id); break;
      
      case TabType.createClient: screen = ClientsScreen(tabId: id); break; // Переиспользуем экран для создания
      case TabType.createAddress: screen = AddressesScreen(tabId: id); break;
      
      case TabType.clientDetails: 
        // Здесь мы бы открыли экран деталей, но пока откроем список для примера
        screen = ClientsScreen(tabId: id); 
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