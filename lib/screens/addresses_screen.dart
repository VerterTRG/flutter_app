import 'package:flutter/material.dart';
import 'package:flutter_app/models/client.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/state.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_app/widgets/components/smart_dropdown.dart';
import 'package:provider/provider.dart';


// --- ADDRESSES SCREEN ---
class AddressesScreen extends StatefulWidget {
  final String tabId;
  final FormArguments? args;
  const AddressesScreen({super.key, required this.tabId, this.args});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  // Смешанные контроллеры: Text и Selection
  final Map<String, dynamic> _controllers = {
    'city': TextEditingController(),
    'zip': TextEditingController(),
    'clientId': SelectionController<String>(),
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
      if (val != null) {
        if (controller is TextEditingController) controller.text = val.toString();
        if (controller is SelectionController) controller.selectedItem = val.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final clientCtrl = _controllers['clientId'] as SelectionController<String>;

    // Fallback: если ничего не выбрано, выбираем первого (опционально)
    if (clientCtrl.selectedItem == null && state.clients.isNotEmpty) {
       // clientCtrl.selectedItem = state.clients.first.id;
    }

    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(children: [
        Expanded(
          child: SmartDropdown<String>(
            controller: clientCtrl,
            label: 'Клиент',
            items: state.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          icon: const Icon(Icons.person_add),
          onPressed: () => context.read<AppState>().openTab(TabType.createClient, sourceTabId: widget.tabId),
        )
      ]),
      const SizedBox(height: 10),
      TextField(controller: _controllers['city'], decoration: const InputDecoration(labelText: 'Город', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: _controllers['zip'], decoration: const InputDecoration(labelText: 'Индекс', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      
      FilledButton(onPressed: () { 
        if (clientCtrl.selectedItem != null) {
          context.read<AppState>().addAddress(clientCtrl.selectedItem!, _controllers['city'].text, _controllers['zip'].text);
        }
      }, child: const Text('Сохранить')),
      
      const Divider(height: 30),
      Expanded(child: ListView(
        children: state.addresses.map((a) => ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(a.city),
          // Можно добавить кнопку копирования адреса аналогично клиентам
        )).toList()
      ))
    ]));
  }
}