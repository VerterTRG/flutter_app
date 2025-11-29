// --- DASHBOARD ---
import 'package:flutter/material.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/state.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final String tabId;
  const DashboardScreen({super.key, required this.tabId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    // Хелпер стал проще: нужны только Тип
    void open(TabType type) => context.read<AppState>().openTab(type);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2, childAspectRatio: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          _InfoCard(TabType.clients, state.clients.length, Colors.blue[100]!, () => open(TabType.clients)),
          _InfoCard(TabType.addresses, state.addresses.length, Colors.green[100]!, () => open(TabType.addresses)),
          _InfoCard(TabType.products, state.products.length, Colors.orange[100]!, () => open(TabType.products)),
          _InfoCard(TabType.invoices, state.invoices.length, Colors.purple[100]!, () => open(TabType.invoices)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TabType type; // Принимаем Тип
  final int count; final Color color; final VoidCallback onTap;
  const _InfoCard(this.type, this.count, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Card(color: color, child: InkWell(onTap: onTap, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(TabConfig.icon(type), color: Theme.of(context).colorScheme.onSecondaryFixed,), // Берем иконку из конфига
      Text('${TabConfig.title(type)}: $count', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryFixed)) // Берем название из конфига
    ]))));
  }
}