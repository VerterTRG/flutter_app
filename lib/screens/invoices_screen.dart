// --- INVOICES ---
import 'package:flutter/material.dart';
import 'package:flutter_app/lib/logic/addresses_cubit.dart';
import 'package:flutter_app/lib/logic/clients_cubit.dart';
import 'package:flutter_app/lib/logic/invoices_cubit.dart';
import 'package:flutter_app/lib/logic/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_app/widgets/components/smart_dropdown.dart';

class InvoicesScreen extends StatefulWidget {
  final String tabId;
  const InvoicesScreen({super.key, required this.tabId}); // Инвойсам пока args не нужны
  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // Для фильтрации адресов нам все же нужно знать текущего клиента,
  // поэтому слушаем его контроллер
  final clientCtrl = SelectionController<String>();
  final addressCtrl = SelectionController<String>();

  @override
  Widget build(BuildContext context) {
    final state = context.read<ClientsCubit>().state;

    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      // 1. ВЫБОР КЛИЕНТА
      SmartDropdown<String>(
        controller: clientCtrl,
        label: 'Клиент',
        items: state.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
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
              
              return Row(children: [
                Expanded(
                  // ! ИСПРАВЛЕНИЕ: Используем SmartDropdown, он внутри проверяет наличие value в items
                  child: SmartDropdown<String>(
                    controller: addressCtrl,
                    label: 'Адрес доставки',
                    items: availableAddresses.map((a) => DropdownMenuItem(value: a.id, child: Text(a.city))).toList(),
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
                    
                    context.read<NavigationCubit>().openTab(
                      TabType.createAddress, 
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
            children: state.invoices.map((i) => ListTile(title: Text('Invoice #${i.id}'))).toList()
          );
        }
      ))
    ]));
  }
}