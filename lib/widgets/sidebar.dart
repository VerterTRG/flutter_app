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
    final menuModules = ModuleRegistry.menuItems;
    
    return Row(
      children: [
        NavigationRail(
          selectedIndex: null,
          // 3. УМНАЯ ОБРАБОТКА НАЖАТИЯ
            onDestinationSelected: (index) {
              // Нам больше не нужен switch!
              // Мы просто берем модуль по индексу из списка
              final selectedModule = menuModules[index];
              
              // И говорим кубиту открыть этот тип
              context.read<NavigationCubit>().openTab(selectedModule.moduleId);
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
