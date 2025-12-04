// 1. УНИВЕРСАЛЬНЫЙ КОНТЕЙНЕР ДАННЫХ
import 'package:flutter_app/core/config.dart';

class FormArguments {
  final Map<String, dynamic> data;
  // Добавляем коллбэк. 
  // dynamic result - потому что мы можем вернуть ID, объект или что угодно.
  final Function(dynamic result)? onResult;

  FormArguments(this.data, {this.onResult});


  /// Универсальный метод получения данных.
  /// Пример использования: 
  /// final name = args.getValue<String>('name');
  /// final age = args.getValue<int>('age');
  T? getValue<T>(String key) {
    final value = data[key];

    // 1. Если значения нет, сразу возвращаем null
    if (value == null) return null;

    // 2. Если значение уже нужного типа (например, там уже лежит int), возвращаем как есть
    if (value is T) {
      return value;
    }

    // 3. Логика приведения типов (Парсинг)
    // Превращаем в строку для безопасного парсинга
    final strValue = value.toString();

    if (T == int) {
      return int.tryParse(strValue) as T?;
    } 
    else if (T == double) {
      return double.tryParse(strValue) as T?;
    } 
    else if (T == String) {
      return strValue as T?;
    } 
    else if (T == bool) {
      // Умеем понимать "true", "True", "1" как правду
      return (strValue.toLowerCase() == 'true' || strValue == '1') as T?;
    }

    // 4. Если тип не поддерживается или не удалось спарсить
    return null;
  }
}

/// Утилита для формирования полного URL к медиа-файлам
String? getFullMediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  
  // Если ссылка уже полная (http/https), возвращаем как есть
  if (path.startsWith('http')) return path;

  // Получаем базовый хост (например, http://127.0.0.1:8000)
  final baseUrl = Uri.parse(AppConfig.baseApiUrl).origin;
  
  // Убедимся, что путь начинается с /
  final normalizedPath = path.startsWith('/') ? path : '/$path';

  return '$baseUrl$normalizedPath';
}