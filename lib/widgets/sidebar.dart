import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/logic/navigation_cubit.dart';
import 'package:flutter_app/modules/auth/logic/auth_cubit.dart';
import 'package:flutter_app/modules/auth/module.dart';
import 'package:flutter_app/utils/common.dart';
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
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      final user = state.user;
                      final fullAvatarUrl = getFullMediaUrl(user.avatarUrl);
                      return InkWell(
                        onTap: () {
                          // Открываем профиль
                          final authModule = AppModulesManager.getModuleById(AuthModule.id);
                          // Мы знаем что у AuthModule openDefault открывает логин, а нам нужен профиль.
                          // Но подождите, forms это интерфейс.
                          // Лучше найти модуль и вызвать конкретный экшн если он есть,
                          // или просто через FormsManager если мы знаем тип.
                          // Но так как мы тут в общем коде, лучше использовать стандартный механизм.
                          // В AuthModule openDefault открывает Login.
                          // Нужно добавить в AuthModule логику: если авторизован -> профиль.
                          // Или просто хардкод пути:
                          (authModule as AuthModule).forms.openProfile.openForm(context);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundImage: fullAvatarUrl == null ? null : NetworkImage(fullAvatarUrl),
                              child: fullAvatarUrl == null ? Text(user.initials) : null,
                            ),
                            const SizedBox(height: 4),
                            Text(state.user.username, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      );
                    } else {
                       return IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: () {
                           final authModule = AppModulesManager.getModuleById(AuthModule.id);
                           authModule?.forms.openDefault.openForm(context);
                        },
                        tooltip: 'Login',
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        VerticalDivider(thickness: 0, width: 1, color: colors.secondary),
      ],
    );
  }
}
