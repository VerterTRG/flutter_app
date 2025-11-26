import 'package:flutter/material.dart';

// --- MODELS ---
class Client { final String id; final String name; Client(this.id, this.name); }
class Address { final String id; final String clientId; final String city; Address(this.id, this.clientId, this.city); }
class Product { final String id; final String name; final double price; Product(this.id, this.name, this.price); }
class Invoice { final String id; final String clientId; final String addressId; Invoice(this.id, this.clientId, this.addressId); }

// --- STORE (PROVIDER) ---
class AppState extends ChangeNotifier {
  final List<Client> clients = [Client('1', 'Иван Иванов')];
  final List<Address> addresses = [];
  final List<Product> products = [];
  final List<Invoice> invoices = [];

  void addClient(String name) {
    clients.add(Client(DateTime.now().toString(), name));
    notifyListeners();
  }

  void addAddress(String clientId, String city) {
    addresses.add(Address(DateTime.now().toString(), clientId, city));
    notifyListeners();
  }

  void addProduct(String name, double price) {
    products.add(Product(DateTime.now().toString(), name, price));
    notifyListeners();
  }

  void addInvoice(String clientId, String addressId) {
    invoices.add(Invoice(DateTime.now().toString(), clientId, addressId));
    notifyListeners();
  }
}
