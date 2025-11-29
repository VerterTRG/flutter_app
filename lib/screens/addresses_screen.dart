import 'package:flutter/material.dart';
import 'package:flutter_app/lib/logic/clients_cubit.dart';
import 'package:flutter_app/lib/logic/navigation_cubit.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/lib/logic/addresses_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_app/widgets/components/smart_dropdown.dart';


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
    final clientCtrl = _controllers['clientId'] as SelectionController<String>;
    final city = _controllers['city'] as TextEditingController;
    final zip = _controllers['zip'] as TextEditingController;           
    // ! Переименовали state -> clientsState, чтобы не было конфликта имен внутри BlocBuilder
    final clientsState = context.read<ClientsCubit>().state;
    final clients = clientsState.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList();

    // Fallback: если ничего не выбрано, выбираем первого (опционально)
    if (clientCtrl.selectedItem == null && clientsState.clients.isNotEmpty) {
       // clientCtrl.selectedItem = clientsState.clients.first.id;
    }

    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(children: [
        Expanded(
          child: SmartDropdown<String>(
            controller: clientCtrl,
            label: 'Клиент',
            items: clients,
            // onChanged: (_) {_controllers.forEach((_, c) => c.clear());}, 
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          icon: const Icon(Icons.person_add),
          onPressed: () => context.read<NavigationCubit>().openTab(TabType.createClient, sourceTabId: widget.tabId),
        )
      ]),
      const SizedBox(height: 10),
      TextField(controller: city, decoration: const InputDecoration(labelText: 'Город', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: zip, decoration: const InputDecoration(labelText: 'Индекс', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      
      FilledButton(onPressed: () { 
        if (clientCtrl.selectedItem != null) {
          context.read<AddressesCubit>().addAddress(clientCtrl.selectedItem!, city.text, zip.text);
        }
      }, child: const Text('Сохранить')),
      
      const Divider(height: 30),
      Expanded(child: BlocBuilder<AddressesCubit, AddressesState>(
        builder: (context, state) {
          return ListView(
            children: state.addresses.map((a) {
              // ! ИСПРАВЛЕНИЕ: Ищем клиента в списке по ID
              final matchedClients = clientsState.clients.where((c) => c.id == a.clientId);
              final clientName = matchedClients.isNotEmpty ? matchedClients.first.name : 'Неизвестный';

              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(a.city),
                subtitle: Text(clientName),
                // Можно добавить кнопку копирования адреса аналогично клиентам
              );
            }).toList()
          );
        }
      ))
    ]));
  }
}