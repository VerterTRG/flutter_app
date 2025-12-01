import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/logic/navigation_cubit.dart';
import 'package:flutter_app/utils/common.dart';

/// Базовый класс для любого действия в системе
abstract class AppAction {
  /// Метод запуска действия
  Future<void> openForm(BuildContext context, {String? sourceTabId, FormArguments? args});
}

/// Стандартное действие: Открыть Таб
class OpenTabAction implements AppAction {
  final String routeId;

  OpenTabAction(this.routeId);

  @override
  Future<void> openForm(BuildContext context, {String? sourceTabId, FormArguments? args}) async {
    // Тут можно добавить проверку прав доступа перед открытием
    // if (!AuthService.canCreateClient) return;

    context.read<NavigationCubit>().openTab(
      routeId,
      sourceTabId: sourceTabId,
      args: args,
    );
  }
}

/// Действие: Открыть Модалку (пример гибкости)
class OpenModalAction implements AppAction {
  final Widget child;
  OpenModalAction(this.child);

  @override
  Future<void> openForm(BuildContext context, {String? sourceTabId, FormArguments? args}) async {
    await showDialog(context: context, builder: (_) => Dialog(child: child));
  }
}