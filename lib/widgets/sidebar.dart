import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/logic/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SideBar extends StatelessWidget {
  const SideBar({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // 1. ПОЛУЧАЕМ СПИСОК ПУНКТОВ МЕНЮ ИЗ РЕЕСТРА
    // Порядок зависит от того, как ты делал register() в main()
    final menuModules = AppModulesManager.menuModules;

    // Получаем текущее состояние навигации для подсветки
    final navState = context.watch<NavigationCubit>().state;

    // Определяем активный модуль
    // Логика: если ID текущего таба начинается с ID модуля, значит этот модуль активен
    String? activeModuleId;
    if (navState.tabs.isNotEmpty && navState.activeTabIndex >= 0) {
       final currentTabId = navState.tabs[navState.activeTabIndex].id;
       // Пример: currentTabId = 'clients/create_123'
       // Мы ищем модуль, чей moduleId ('clients') является частью этого ID
       // Самый простой способ: разбить по '/' или использовать startsWith
       // Для надежности можно спросить у Реестра, кто владелец текущего таба (но таб ID сложный).
       // Упрощенная проверка:
       for (var m in menuModules) {
         if (currentTabId.startsWith(m.moduleId)) {
           activeModuleId = m.moduleId;
           break;
         }
       }
    }

    // Вычисляем индекс для NavigationRail
    int? selectedIndex;
    if (activeModuleId != null) {
      final idx = menuModules.indexWhere((m) => m.moduleId == activeModuleId);
      if (idx != -1) selectedIndex = idx;
    }
    
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          // 3. УМНАЯ ОБРАБОТКА НАЖАТИЯ
            onDestinationSelected: (index) {
              // Нам больше не нужен switch!
              // Мы просто берем модуль по индексу из списка
              final selectedModule = menuModules[index];
              selectedModule.forms.openDefault.openForm(context); // Открываем форму по умолчанию
            },
          labelType: NavigationRailLabelType.all,
          destinations: menuModules.map((module) {
              return NavigationRailDestination(
                icon: Icon(module.icon), // Берем иконку прямо из модуля
                label: Text(module.title), // Берем название прямо из модуля
              );
            }).toList(),
        ),
        VerticalDivider(thickness: 0, width: 1, color: colors.secondary),
      ],
    );
  }
}
