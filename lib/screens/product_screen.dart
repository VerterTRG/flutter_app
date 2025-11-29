// --- PRODUCTS ---
import 'package:flutter/material.dart';
import 'package:flutter_app/state.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  final String tabId;
  const ProductsScreen({super.key, required this.tabId});
  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(); final priceCtrl = TextEditingController();
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название')),
      TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Цена'), keyboardType: TextInputType.number),
      ElevatedButton(onPressed: () => context.read<AppState>().addProduct(nameCtrl.text, double.tryParse(priceCtrl.text) ?? 0), child: const Text('Добавить')),
      Expanded(child: ListView(children: context.watch<AppState>().products.map((p) => ListTile(title: Text(p.name), trailing: Text('\$${p.price}'))).toList()))
    ]));
  }
}