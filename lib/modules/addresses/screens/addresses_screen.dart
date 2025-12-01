import 'package:flutter/material.dart';
import 'package:flutter_app/logic/clients_cubit.dart';
import 'package:flutter_app/logic/navigation_cubit.dart';
import 'package:flutter_app/logic/addresses_cubit.dart';
import 'package:flutter_app/modules/clients/module.dart';
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

  void _openCreateClientTab() {
    final clientCtrl = _controllers['clientId'] as SelectionController<String>;
    
    final form = Clients().forms.create;

    form.openForm(context, sourceTabId: widget.tabId, args: FormArguments(
        {}, // Пустые аргументы
        onResult: (result) {
          // При получении результата (ID нового клиента) обновляем контроллер
          if (result is String) {
            clientCtrl.selectedItem = result;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientCtrl = _controllers['clientId'] as SelectionController<String>;
    final city = _controllers['city'] as TextEditingController;
    final zip = _controllers['zip'] as TextEditingController;           
    // ! ИСПРАВЛЕНИЕ: Используем watch вместо read.
    // Теперь при добавлении клиента экран перестроится, список clients обновится,
    // и SmartDropdown сможет найти и отобразить новый ID.
    final clientsState = context.watch<ClientsCubit>().state;
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
          // ! ИСПРАВЛЕНИЕ: Разрешаем создавать клиента всегда (убрали проверку на null)
          // и не передаем текущий ID, так как создаем нового.
          onPressed: _openCreateClientTab,
        )
      ]),
      const SizedBox(height: 10),
      TextField(controller: city, decoration: const InputDecoration(labelText: 'Город', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: zip, decoration: const InputDecoration(labelText: 'Индекс', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      
      FilledButton(onPressed: () { 
        if (clientCtrl.selectedItem == null) return;

        final newAddressId = context.read<AddressesCubit>().addAddress(clientCtrl.selectedItem!, city.text, zip.text);

        final createdCity = city.text.trim();
        // 2. Очищаем форму
        _controllers.forEach((_, c) => c.clear() ?? {});

        if (widget.args?.onResult != null) {
          widget.args!.onResult!(newAddressId);
          
          // Опционально: Можно даже закрыть этот таб автоматически
          final navCubit = context.read<NavigationCubit>();
          final index = navCubit.state.tabs.indexWhere((t) => t.id == widget.tabId);
          if (index != -1) {
            navCubit.closeTab(index);
          }

          // Показываем уведомление
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Адрес "ID: $newAddressId" - $createdCity создан для клиента "${clientsState.clients.firstWhere((c) => c.id == clientCtrl.selectedItem).name}"')));
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