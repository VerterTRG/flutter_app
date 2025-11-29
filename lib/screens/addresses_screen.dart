import 'package:flutter/material.dart';
import 'package:flutter_app/models/client.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/state.dart';
import 'package:provider/provider.dart';


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
          icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary), 
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