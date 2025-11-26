import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'models.dart'; // <--- Импортируем типы

// --- DASHBOARD ---
class DashboardScreen extends StatelessWidget {
  final String tabId;
  const DashboardScreen({super.key, required this.tabId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    // Хелпер стал проще: нужны только Тип
    void open(TabType type) => context.read<AppState>().openTab(type);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2, childAspectRatio: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          _InfoCard(TabType.clients, state.clients.length, Colors.blue[100]!, () => open(TabType.clients)),
          _InfoCard(TabType.addresses, state.addresses.length, Colors.green[100]!, () => open(TabType.addresses)),
          _InfoCard(TabType.products, state.products.length, Colors.orange[100]!, () => open(TabType.products)),
          _InfoCard(TabType.invoices, state.invoices.length, Colors.purple[100]!, () => open(TabType.invoices)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TabType type; // Принимаем Тип
  final int count; final Color color; final VoidCallback onTap;
  const _InfoCard(this.type, this.count, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Card(color: color, child: InkWell(onTap: onTap, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(TabConfig.icon(type)), // Берем иконку из конфига
      Text('${TabConfig.title(type)}: $count') // Берем название из конфига
    ]))));
  }
}

// --- CLIENTS ---
class ClientsScreen extends StatelessWidget {
  final String tabId;
  const ClientsScreen({super.key, required this.tabId});
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final state = context.watch<AppState>();
    
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ФИО Клиента')),
      ElevatedButton(onPressed: () { context.read<AppState>().addClient(nameController.text); nameController.clear(); }, child: const Text('Создать')),
      Expanded(child: ListView(
        children: state.clients.map((c) => ListTile(
          title: Text(c.name),
          // ПРИМЕР: Клик по клиенту открывает таб с его именем
          onTap: () => context.read<AppState>().openTab(TabType.clientDetails, entity: c),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        )).toList()
      ))
    ]));
  }
}

// --- ADDRESSES ---
class AddressesScreen extends StatelessWidget {
  final String tabId;
  const AddressesScreen({super.key, required this.tabId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cityController = TextEditingController();
    String? selectedClientId = state.clients.isNotEmpty ? state.clients.first.id : null;

    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(value: selectedClientId, items: state.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (val) => selectedClientId = val, decoration: const InputDecoration(labelText: 'Клиент'))),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.blue), 
          // ! БЕЗ ХАРДКОДА: Просто передаем Тип и ID текущего таба
          onPressed: () => context.read<AppState>().openTab(TabType.createClient, sourceTabId: tabId)
        )
      ]),
      TextField(controller: cityController, decoration: const InputDecoration(labelText: 'Адрес')),
      ElevatedButton(onPressed: () { if (selectedClientId != null) context.read<AppState>().addAddress(selectedClientId!, cityController.text); }, child: const Text('Сохранить')),
      Expanded(child: ListView(children: state.addresses.map((a) => ListTile(title: Text(a.city), subtitle: Text(state.clients.firstWhere((c) => c.id == a.clientId, orElse: () => Client('0', '?')).name))).toList()))
    ]));
  }
}

// --- PRODUCTS ---
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

// --- INVOICES ---
class InvoicesScreen extends StatefulWidget { final String tabId; const InvoicesScreen({super.key, required this.tabId}); @override State<InvoicesScreen> createState() => _InvoicesScreenState(); }
class _InvoicesScreenState extends State<InvoicesScreen> {
  String? _clientId; String? _addrId;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final addresses = state.addresses.where((a) => a.clientId == _clientId).toList();
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      DropdownButtonFormField<String>(value: _clientId, hint: const Text('Клиент'), items: state.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => setState(() { _clientId = v; _addrId = null; })),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(value: _addrId, hint: const Text('Адрес'), items: addresses.map((a) => DropdownMenuItem(value: a.id, child: Text(a.city))).toList(), onChanged: (v) => setState(() => _addrId = v))),
        if (_clientId != null) 
          IconButton(
            icon: const Icon(Icons.add), 
            // ! БЕЗ ХАРДКОДА: Создаем Адрес из Инвойса
            onPressed: () => context.read<AppState>().openTab(TabType.createAddress, sourceTabId: widget.tabId)
          )
      ]),
      ElevatedButton(onPressed: (_clientId != null && _addrId != null) ? () => context.read<AppState>().addInvoice(_clientId!, _addrId!) : null, child: const Text('Создать Инвойс')),
      Expanded(child: ListView(children: state.invoices.map((i) => ListTile(title: Text('Инвойс #${i.id.substring(0,4)}'))).toList()))
    ]));
  }
}