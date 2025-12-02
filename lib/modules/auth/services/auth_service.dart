import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Сервис для работы с аутентификацией.
/// Отвечает за общение с API и хранение токенов.
class AuthService {
  // Базовый URL API
  // В реальном приложении лучше вынести в конфиг.
  // Для Android эмулятора используйте 10.0.2.2 вместо 127.0.0.1
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  final FlutterSecureStorage _storage;
  final http.Client _httpClient;

  AuthService({FlutterSecureStorage? storage, http.Client? httpClient})
      : _storage = storage ?? const FlutterSecureStorage(),
        _httpClient = httpClient ?? http.Client();

  /// Ключи для хранения токенов
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'username';

  /// Получение токена (Login)
  /// POST /token/obtain
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/token/obtain');
    try {
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access'], data['refresh']);
        await _storage.write(key: _usernameKey, value: username);
        return data;
      } else {
        throw Exception('Login failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Обновление токена
  /// POST /token/refresh
  Future<String?> refreshToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return null;

    final url = Uri.parse('$_baseUrl/token/refresh');
    try {
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'];
        // API может вернуть новый refresh токен, а может и нет.
        // NinjaJWTDefaultController обычно возвращает access.
        if (data.containsKey('refresh')) {
           await _saveTokens(newAccess, data['refresh']);
        } else {
           await _storage.write(key: _accessTokenKey, value: newAccess);
        }
        return newAccess;
      } else {
        // Если refresh не удался, сбрасываем токены
        await logout();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Проверка токена
  /// POST /token/verify
  Future<bool> verifyToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/token/verify');
    try {
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Выход (удаление токенов)
  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _usernameKey);
  }

  /// Получение текущего access токена
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Получение сохраненного имени пользователя
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// Сохранение токенов
  Future<void> _saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }
}
