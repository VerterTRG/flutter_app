import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/core/config.dart';
import 'package:flutter_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message; // Возвращаем только сообщение
}
/// Сервис для работы с аутентификацией.
/// Отвечает за общение с API и хранение токенов.
class AuthService {
  // Базовый URL API
  // В реальном приложении лучше вынести в конфиг.
  // Для Android эмулятора используйте 10.0.2.2 вместо 127.0.0.1
  String get _baseApiUrl => '${AppConfig.baseApiUrl}/auth';

  final FlutterSecureStorage _storage;
  final http.Client _httpClient;

  AuthService({FlutterSecureStorage? storage, http.Client? httpClient})
      : _storage = storage ?? const FlutterSecureStorage(),
        _httpClient = httpClient ?? http.Client();

  /// Ключи для хранения токенов
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  /// Получение токена (Login)
  /// POST /token/obtain
  Future<User> login(String username, String password) async {
    final url = Uri.parse('$_baseApiUrl/token/pair');
    try {
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access'], data['refresh']);

        // Создаем модель пользователя.
        // В идеале API должен возвращать данные пользователя.
        // Если API возвращает только токены, мы создаем User из введенного username.
        // Если API начнет возвращать user object, мы обновим этот код.
        final user = User(username: username);
        await _saveUser(user);

        return user;
      } else {
        throw AuthException('Login failed: ${response.statusCode} ${response.body}');
      }
    } on http.ClientException catch (e) {
      debugPrint('Server error: $e');
      throw Exception('Server is unreachable. Please try again later.');
    } on AuthException catch(e) {
      debugPrint('Login error: $e');
      throw Exception('Invalid credentials. Please check your username and password.');
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Обновление токена
  /// POST /token/refresh
  Future<String?> refreshToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return null;

    final url = Uri.parse('$_baseApiUrl/token/refresh');
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

    final url = Uri.parse('$_baseApiUrl/token/verify');
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
    await _storage.delete(key: _userKey);
  }

  /// Получение текущего access токена
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Получение сохраненного пользователя
  Future<User?> getUser() async {
    final jsonString = await _storage.read(key: _userKey);
    if (jsonString != null) {
      try {
        return User.fromJson(jsonDecode(jsonString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Сохранение пользователя
  Future<void> _saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  /// Сохранение токенов
  Future<void> _saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }
}
