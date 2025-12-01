import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'actions/delete_client_action.dart';
import 'screens/clients_screen.dart';
import 'routes.dart';



class Clients implements AppModule {

  // === SINGLETON (Чтобы писать Clients() везде) ===
  static final Clients _instance = Clients._internal();
  factory Clients() => _instance;
  Clients._internal();

  @override
  String get moduleId => 'clients';

  @override
  bool get isMenuItem =>  true;

  @override
  String get title => 'Клиенты';

  @override
  IconData get icon => Icons.people;

  // === РЕАЛИЗАЦИЯ API (Фасад) ===
  @override
  final FormsManager forms = FormsManager();

  @override
  final ActionsManager actions = ActionsManager();



  // TODO: Добавить остальные экраны модуля
  @override
  Map<String, AppModuleRoute> get routes => {
        ClientsRoutes.list: AppModuleRoute(title: 'Список контрагентов', icon: Icons.people, builder: (tabId, args) => ClientsScreen(tabId: tabId, args: args)),
        ClientsRoutes.create: AppModuleRoute(title: 'Создание контрагента', icon: Icons.person_add, builder: (tabId, args) => ClientsScreen(tabId: tabId, args: args)),
        ClientsRoutes.details: AppModuleRoute(title: 'Детали контрагента', icon: Icons.person, builder: (tabId, args) => ClientsScreen(tabId: tabId, args: args)),
      };
}

class FormsManager implements BaseFormsManager {

  @override
  AppAction get openDefault => list;
  
  final AppAction list = OpenTabAction(ClientsRoutes.list);
  final AppAction create = OpenTabAction(ClientsRoutes.create);
  final AppAction edit = OpenTabAction(ClientsRoutes.details);
}

class ActionsManager implements BaseActionsManager {
  // Тут подключаем сложные бизнес-действия
  final AppAction delete = DeleteClientAction(); 
  
  // Можно добавить и простые методы, если не нужен полноценный Action класс
  Future<void> validate(String id) async {
     debugPrint("Validating $id...");
  }
}