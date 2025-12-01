// --- PRODUCTS ---
import 'package:flutter/material.dart';
import 'package:flutter_app/logic/products_cubit.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProductsScreen extends StatelessWidget {
  final String tabId;
  const ProductsScreen({super.key, required this.tabId, FormArguments? args});
  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(); final priceCtrl = TextEditingController();
    final cubit = context.read<ProductsCubit>();
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название')),
      TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Цена'), keyboardType: TextInputType.number),
      ElevatedButton(onPressed: () => cubit.addProduct(nameCtrl.text, double.tryParse(priceCtrl.text) ?? 0), child: const Text('Добавить')),
      Expanded(child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          return ListView(children: state.products.map((p) => ListTile(title: Text(p.name), trailing: Text('\$${p.price}'))).toList());
        }
      ))
    ]));
  }
}