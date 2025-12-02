// --- INVOICES ---
import 'package:flutter/material.dart';
import 'package:flutter_app/logic/addresses_cubit.dart';
import 'package:flutter_app/logic/clients_cubit.dart';
import 'package:flutter_app/logic/invoices_cubit.dart';
import 'package:flutter_app/modules/addresses/module.dart';
import 'package:flutter_app/modules/invoices/module.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_app/widgets/components/smart_dropdown.dart';

class InvoicesScreen extends StatefulWidget {
  final String tabId;
  final FormArguments? args;
  const InvoicesScreen({super.key, required this.tabId, this.args}); // Инвойсам пока args не нужны
  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {

  // 1. Объявляем контроллеры, которые используются в UI
  final clientCtrl = SelectionController<String>();
  final addressCtrl = SelectionController<String>();

  // 2. Создаем карту ссылок на эти же контроллеры для _fillForm
  late final Map<String, dynamic> _controllers = {
    'clientId': clientCtrl,
    'addressId': addressCtrl,
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
    final state = context.read<ClientsCubit>().state;
    final clients = state.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList();

    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      // 1. ВЫБОР КЛИЕНТА
      SmartDropdown<String>(
        controller: clientCtrl,
        label: 'Клиент',
        items: clients,
        // ! ВАЖНО: При смене клиента сбрасываем выбранный адрес
        onChanged: (_) => addressCtrl.selectedItem = null,
      ),
      const SizedBox(height: 10),

      // 2. ВЫБОР АДРЕСА (Зависимый)
      // Используем ValueListenableBuilder чтобы перерисовывать ТОЛЬКО этот блок при смене клиента
      BlocBuilder<AddressesCubit, AddressesState>(
        builder: (context, addressesState) {
          return ValueListenableBuilder<String?>(
            valueListenable: clientCtrl,
            builder: (context, clientId, _) {
              // Фильтруем адреса
              final availableAddresses = addressesState.addresses.where((a) => a.clientId == clientId).toList();
              final addresses = availableAddresses.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.city}, ${a.zip}'))).toList();
              return Row(children: [
                Expanded(
                  // ! ИСПРАВЛЕНИЕ: Используем SmartDropdown, он внутри проверяет наличие value в items
                  child: SmartDropdown<String>(
                    controller: addressCtrl,
                    label: 'Адрес доставки',
                    items: addresses,
                  ),
                ),
                const SizedBox(width: 10),
                
                // КНОПКА "ДОБАВИТЬ АДРЕС"
                // Активна только если выбран клиент
                IconButton.filledTonal(
                  icon: const Icon(Icons.add_location_alt),
                  onPressed: clientId == null ? null : () {
                    // ! ПЕРЕДАЕМ ID КЛИЕНТА В ФОРМУ СОЗДАНИЯ АДРЕСА
                    final args = FormArguments({'clientId': clientId}, 
                      onResult: (newAddressId) {
                        // После создания нового адреса сразу его выбираем
                        addressCtrl.selectedItem = newAddressId?.toString();
                      }
                    );
                    
                    final form = Addresses().forms.create;
                    form.openForm(
                      context, 
                      sourceTabId: widget.tabId, 
                      args: args
                    );
                  },
                )
              ]);
            }
          );
        }
      ),
      
      const SizedBox(height: 20),
      FilledButton(onPressed: () {
        if (clientCtrl.selectedItem != null && addressCtrl.selectedItem != null) {
          context.read<InvoicesCubit>().addInvoice(clientCtrl.selectedItem!, addressCtrl.selectedItem!);
        }
      }, child: const Text('Создать Инвойс')),
      
      const Divider(height: 30),
      Expanded(child: BlocBuilder<InvoicesCubit, InvoicesState>(
        builder: (context, state) {
          return ListView(
            children: state.invoices.map((i) => ListTile(onTap: () => {Invoices().forms.details.openForm(
              context, 
              sourceTabId: widget.tabId,
              args: FormArguments({'id': i.id, 'clientId': i.clientId, 'addressId': i.addressId})
            )}, title: Text('Инвойс ID: ${i.id}'), subtitle: Text('Клиент ID: ${i.clientId}, Адрес ID: ${i.addressId}'))).toList()
          );
        }
      ))
    ]));
  }
}