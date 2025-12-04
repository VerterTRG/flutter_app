import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/modules/addresses/module.dart';
import 'package:flutter_app/modules/auth/module.dart';
import 'package:flutter_app/modules/clients/module.dart';
import 'package:flutter_app/modules/dashboard/module.dart';
import 'package:flutter_app/modules/invoices/module.dart';
import 'package:flutter_app/modules/products/module.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseApiUrl => dotenv.env['API_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  /// Список модулей приложения для регистрации
  static final List<AppModule> modules = [
    Dashboard(),
    Clients(),
    Addresses(),
    Products(),
    Invoices(),
    AuthModule(),
  ];
}