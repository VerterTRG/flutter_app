// --- CLIENTS ---
import 'package:flutter/material.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/state.dart';
import 'package:provider/provider.dart';

class ClientsScreen extends StatelessWidget {
  final String tabId;
  const ClientsScreen({super.key, required this.tabId});
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final state = context.watch<AppState>();
    
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ФИО Клиента')),
      FilledButton(onPressed: () { context.read<AppState>().addClient(nameController.text); nameController.clear(); }, child: const Text('Создать')),
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