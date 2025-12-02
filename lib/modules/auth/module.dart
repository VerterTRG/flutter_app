import 'package:flutter/material.dart';
import 'package:flutter_app/core/actions.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/modules/auth/routes.dart';
import 'package:flutter_app/modules/auth/screens/login_screen.dart';
import 'package:flutter_app/modules/auth/screens/profile_screen.dart';

class AuthModule implements AppModule {

  static const String id = 'auth';

  @override
  String get moduleId => id;

  @override
  // Модуль авторизации не обязательно показывать в главном меню
  // Но если нужно - можно поставить true
  bool get isMenuItem => false;

  @override
  String get title => 'Auth';

  @override
  IconData get icon => Icons.security;

  @override
  final FormsManager forms = FormsManager();

  @override
  final ActionsManager actions = ActionsManager();

  @override
  Map<String, AppModuleRoute> get routes => {
        AuthRoutes.login: AppModuleRoute(
            title: 'Login',
            builder: (tabId, args) => LoginScreen(tabId: tabId)),
        AuthRoutes.profile: AppModuleRoute(
            title: 'Profile',
            builder: (tabId, args) => ProfileScreen(tabId: tabId)),
      };
}

class FormsManager implements BaseFormsManager {
  @override
  AppAction get openDefault => openLogin;

  final AppAction openLogin = OpenTabAction(AuthRoutes.login);
  final AppAction openProfile = OpenTabAction(AuthRoutes.profile);
}

class ActionsManager implements BaseActionsManager {
  // Тут могут быть действия
}
