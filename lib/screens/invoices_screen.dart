// --- INVOICES ---
import 'package:flutter/material.dart';
import 'package:flutter_app/models/tab_config.dart';
import 'package:flutter_app/state.dart';
import 'package:provider/provider.dart';



class InvoicesScreen extends StatefulWidget { final String tabId; const InvoicesScreen({super.key, required this.tabId}); @override State<InvoicesScreen> createState() => _InvoicesScreenState(); }
class _InvoicesScreenState extends State<InvoicesScreen> {
  String? _clientId; String? _addrId;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final addresses = state.addresses.where((a) => a.clientId == _clientId).toList();
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      DropdownButtonFormField<String>(value: _clientId, hint: const Text('Клиент'), items: state.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => setState(() { _clientId = v; _addrId = null; })),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(value: _addrId, hint: const Text('Адрес'), items: addresses.map((a) => DropdownMenuItem(value: a.id, child: Text(a.city))).toList(), onChanged: (v) => setState(() => _addrId = v))),
        if (_clientId != null) 
          IconButton(
            icon: const Icon(Icons.add), 
            // ! БЕЗ ХАРДКОДА: Создаем Адрес из Инвойса
            onPressed: () => context.read<AppState>().openTab(TabType.createAddress, sourceTabId: widget.tabId)
          )
      ]),
      ElevatedButton(onPressed: (_clientId != null && _addrId != null) ? () => context.read<AppState>().addInvoice(_clientId!, _addrId!) : null, child: const Text('Создать Инвойс')),
      Expanded(child: ListView(children: state.invoices.map((i) => ListTile(title: Text('Инвойс #${i.id.substring(0,4)}'))).toList()))
    ]));
  }
}