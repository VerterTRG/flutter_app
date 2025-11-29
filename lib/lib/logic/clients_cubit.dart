import 'package:flutter_app/models/client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Состояние клиентов
class ClientsState {
  final List<Client> clients;
  
  ClientsState(this.clients);
}

class ClientsCubit extends Cubit<ClientsState> {
  // Начальные данные
  ClientsCubit() : super(ClientsState([
    Client('1', 'Иван Иванов', email: 'ivan@test.com'),
    Client('2', 'Петр Петров', email: 'petr@test.com'),
  ]));

  void addClient(String name, String email) {
    final newClient = Client(DateTime.now().millisecondsSinceEpoch.toString(), name, email: email);
    
    // Создаем НОВЫЙ список (immutability)
    final newList = List<Client>.from(state.clients)..add(newClient);
    
    emit(ClientsState(newList));
  }
  
  // Метод поиска (для toCreateAddressArgs)
  Client? findById(String id) {
    try {
      return state.clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}