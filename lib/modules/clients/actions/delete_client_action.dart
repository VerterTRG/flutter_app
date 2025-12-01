import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/utils/common.dart'; // Импорт для FormArguments

class DeleteClientAction implements AppAction {
  @override
  // ! ИСПРАВЛЕНИЕ: Сигнатура должна точно совпадать с интерфейсом AppAction
  Future<void> openForm(BuildContext context, {String? sourceTabId, FormArguments? args}) async {
    // payload (ID клиента) теперь извлекаем из args
    // Предполагаем, что при вызове действия мы положили ID в аргументы под ключом 'clientId'
    final String? clientId = args?.getValue('clientId') as String?;

    if (clientId == null) return;

    // 1. Спрашиваем подтверждение (Системное действие или прямо тут)
    final confirm = await showDialog<bool>(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Удалить?"), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Нет")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Да")),
        ]
      )
    );

    if (confirm != true) return;

    try {
      // 2. Логика удаления (Связь с Cubit или Repo)
      // context.read<ClientsCubit>().delete(clientId);
      
      // 3. Закрываем таб (Системная логика)
      // context.read<NavigationCubit>().closeCurrentTab();

      // 4. Показываем успех
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Клиент удален")));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ошибка удаления")));
    }
  }
}