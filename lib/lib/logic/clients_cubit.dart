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

  String addClient(String name, String email) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newClient = Client(newId, name, email: email);
    
    final newList = List<Client>.from(state.clients)..add(newClient);
    emit(ClientsState(newList));

    return newId; // <--- ВОЗВРАЩАЕМ ID
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