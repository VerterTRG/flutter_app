// --- DASHBOARD ---
import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/logic/addresses_cubit.dart';
import 'package:flutter_app/logic/clients_cubit.dart';
import 'package:flutter_app/logic/invoices_cubit.dart';
import 'package:flutter_app/logic/products_cubit.dart';
import 'package:flutter_app/modules/addresses/module.dart';
import 'package:flutter_app/modules/clients/module.dart';
import 'package:flutter_app/modules/invoices/module.dart';
import 'package:flutter_app/modules/products/module.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DashboardScreen extends StatelessWidget {
  final String tabId;
  const DashboardScreen({super.key, required this.tabId});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2, childAspectRatio: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          BlocSelector<ClientsCubit, ClientsState, int>(
            selector: (state) => state.clients.length,
            builder: (context, clientCount) => _InfoCard(moduleConfig: Clients(), count: clientCount, color: Colors.blue[100]!, onTap: () => Clients().forms.openDefault.openForm(context)),
          ),
          BlocSelector<AddressesCubit, AddressesState, int>(
            selector: (state) => state.addresses.length,
            builder: (context, addressCount) => _InfoCard(moduleConfig: Addresses(), count: addressCount, color: Colors.green[100]!, onTap: () => Addresses().forms.openDefault.openForm(context)),
          ),
          BlocSelector<ProductsCubit, ProductsState, int>(
            selector: (state) => state.products.length,
            builder: (context, productCount) => _InfoCard(moduleConfig: Products(), count: productCount, color: Colors.orange[100]!, onTap: () => Products().forms.openDefault.openForm(context)),
          ),
          BlocSelector<InvoicesCubit, InvoicesState, int>(
            selector: (state) => state.invoices.length,
            builder: (context, invoiceCount) => _InfoCard(moduleConfig: Invoices(), count: invoiceCount, color: Colors.purple[100]!, onTap: () => Invoices().forms.openDefault.openForm(context)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AppModule moduleConfig;
  final int count; final Color color; final VoidCallback onTap;
  const _InfoCard({required this.moduleConfig, required this.count, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {

    
    // 2. Определяем данные (с защитой от null, если модуль вдруг не найден)
    final iconData = moduleConfig.icon; // Заглушка, если не нашли
    final title = moduleConfig.title;// Если названия нет, покажем сам ID

    final fgColor = Theme.of(context).colorScheme.onSecondaryFixed;
    
    return Card(color: color, child: InkWell(onTap: onTap, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(iconData, color: fgColor,), // Берем иконку из реестра модулей
      Text('$title: $count', style: TextStyle(color: fgColor)) // Берем название из реестра модулей
    ]))));
  }
}