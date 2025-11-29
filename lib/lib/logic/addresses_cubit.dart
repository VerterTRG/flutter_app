import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/models/address.dart';

class AddressesState {
  final List<Address> addresses;
  
  AddressesState(this.addresses);
}

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit() : super(AddressesState([]));

  void addAddress(String clientId, String city, String? zip) {
    final newAddress = Address(DateTime.now().millisecondsSinceEpoch.toString(), clientId, city, zip);
    final newList = List<Address>.from(state.addresses)..add(newAddress);
    emit(AddressesState(newList));
  }

  Address? findById(String id) {
    try {
      return state.addresses.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}