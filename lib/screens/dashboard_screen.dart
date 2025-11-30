// --- DASHBOARD ---
import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/logic/addresses_cubit.dart';
import 'package:flutter_app/logic/clients_cubit.dart';
import 'package:flutter_app/logic/invoices_cubit.dart';
import 'package:flutter_app/logic/navigation_cubit.dart';
import 'package:flutter_app/logic/products_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DashboardScreen extends StatelessWidget {
  final String tabId;
  const DashboardScreen({super.key, required this.tabId});

  @override
  Widget build(BuildContext context) {
    // final state = context.read<NavigationState>();
    
    // Хелпер стал проще: нужны только Тип
    void open(String id) => context.read<NavigationCubit>().openTab(id);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2, childAspectRatio: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          _InfoCard(Routes.clients, context.read<ClientsCubit>().state.clients.length, Colors.blue[100]!, () => open(Routes.clients)),
          _InfoCard(Routes.addresses, context.read<AddressesCubit>().state.addresses.length, Colors.green[100]!, () => open(Routes.addresses)),
          _InfoCard(Routes.products, context.read<ProductsCubit>().state.products.length, Colors.orange[100]!, () => open(Routes.products)),
          _InfoCard(Routes.invoices, context.read<InvoicesCubit>().state.invoices.length, Colors.purple[100]!, () => open(Routes.invoices)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String tabId; // Принимаем Тип
  final int count; final Color color; final VoidCallback onTap;
  const _InfoCard(this.tabId, this.count, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    // 1. Пытаемся найти модуль в реестре по строковому ID
    final module = ModuleRegistry.get(tabId);
    
    // 2. Определяем данные (с защитой от null, если модуль вдруг не найден)
    final iconData = module?.icon ?? Icons.help_outline; // Заглушка, если не нашли
    final title = module?.title ?? tabId; // Если названия нет, покажем сам ID

    final fgColor = Theme.of(context).colorScheme.onSecondaryFixed;
    
    return Card(color: color, child: InkWell(onTap: onTap, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(iconData, color: fgColor,), // Берем иконку из реестра модулей
      Text('$title: $count', style: TextStyle(color: fgColor)) // Берем название из реестра модулей
    ]))));
  }
}