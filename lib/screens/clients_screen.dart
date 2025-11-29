// --- CLIENTS ---
import 'package:flutter/material.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/state.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:provider/provider.dart';


class ClientsScreen extends StatefulWidget {
  final String tabId;
  final FormArguments? args;
  const ClientsScreen({super.key, required this.tabId, this.args});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  // Карта контроллеров
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _fillForm();
  }

  void _fillForm() {
    if (widget.args == null) return;
    _controllers.forEach((key, controller) {
      final val = widget.args!.getValue(key);
      if (val != null) controller.text = val.toString();
    });
  }
  
  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: _controllers['name'], decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: _controllers['email'], decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      FilledButton(
        onPressed: () { 
          context.read<AppState>().addClient(_controllers['name']!.text); 
          // Очистка
          _controllers.forEach((_, c) => c.clear());
        }, 
        child: const Text('Сохранить')
      ),
      const Divider(height: 30),
      Expanded(child: ListView(
        children: state.clients.map((c) => ListTile(
          leading: CircleAvatar(child: Text(c.name[0])),
          title: Text(c.name),
          subtitle: c.email.isNotEmpty ? Text(c.email) : null,
          trailing: IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'Копировать',
            onPressed: () {
              // ! КОПИРОВАНИЕ ЧЕРЕЗ МОДЕЛЬ
              context.read<AppState>().openTab(
                TabType.createClient, 
                sourceTabId: widget.tabId,
                args: c.toFormArgs()
              );
            },
          ),
        )).toList()
      ))
    ]));
  }
}