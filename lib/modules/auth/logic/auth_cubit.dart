import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/modules/auth/services/auth_service.dart';

// --- States ---

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({AuthService? authService})
    : _authService = authService ?? AuthService(),
      super(AuthInitial());

  /// Проверка статуса авторизации при старте приложения
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      // Сначала пробуем верифицировать текущий токен
      final isValid = await _authService.verifyToken();

      if (isValid) {
        // Пробуем получить актуальные данные
        try {
          final user = await _authService.getUserProfile();
           emit(AuthAuthenticated(user: user));
        } catch (_) {
           // Если не вышло, берем из кэша
           final savedUser = await _authService.getUser();
           if (savedUser != null) {
              emit(AuthAuthenticated(user: savedUser));
           } else {
              // Если и в кэше нет - беда, но токен валиден. Попробуем обновить токен?
              // Или просто считаем что не авторизован?
              // Давайте считать Unauthenticated чтобы не было битого стейта.
              emit(AuthUnauthenticated());
           }
        }
      } else {
        // Если не валиден, пробуем обновить
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
           // Токен обновили, пробуем получить данные
           try {
             final user = await _authService.getUserProfile();
             emit(AuthAuthenticated(user: user));
           } catch (_) {
             final savedUser = await _authService.getUser();
             if (savedUser != null) {
                emit(AuthAuthenticated(user: savedUser));
             } else {
                emit(AuthUnauthenticated());
             }
           }
        } else {
          emit(AuthUnauthenticated());
        }
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Обновление профиля
  Future<void> updateProfile({String? firstName, String? lastName, String? phone}) async {
    if (state is AuthAuthenticated) {
      try {
        final updatedUser = await _authService.updateProfile(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        );
        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
        emit(AuthFailure(e.toString()));
        // Возвращаем старый стейт, если ошибка (но Cubit не позволяет "вернуть", он эмитит новый).
        // Лучше эмитить Failure, а потом снова Authenticated со старым юзером?
        // Или просто Failure и UI покажет снекбар.
        // Но тогда UI останется в Failure? Нет, надо восстановить стейт.
        // Пока просто Failure, UI должен обработать.
      }
    }
  }

  /// Смена пароля
  Future<void> changePassword(String oldPassword, String newPassword, String newPasswordConfirm) async {
     try {
       await _authService.changePassword(oldPassword, newPassword, newPasswordConfirm);
     } catch (e) {
       throw e; // Пробрасываем ошибку чтобы UI мог показать
     }
  }

  /// Загрузка логотипа
  Future<void> uploadLogo(File file) async {
    if (state is AuthAuthenticated) {
      try {
        final updatedUser = await _authService.uploadLogo(file);
        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
         emit(AuthFailure(e.toString()));
      }
    }
  }

  /// Вход в систему
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(username, password);
      // После успешного входа
      emit(AuthAuthenticated(user: user));
    } on AuthException catch (e) {
      // Тут e уже имеет тип AuthException и поле message
      emit(AuthFailure(e.message));
      emit(AuthUnauthenticated());
    } catch (e) {
      debugPrint('Login error in Cubit: $e');
      // Для всех остальных непредвиденных ошибок
      // emit(AuthFailure("Произошла неизвестная ошибка"));
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  /// Выход из системы
  Future<void> logout() async {
    emit(AuthLoading());
    await _authService.logout();
    emit(AuthUnauthenticated());
  }
}
