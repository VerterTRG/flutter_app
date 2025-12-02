import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/modules/auth/services/auth_service.dart';
import 'package:flutter_app/modules/auth/models/user.dart';

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
      final savedUser = await _authService.getUser();

      if (isValid && savedUser != null) {
        // Если валиден, мы авторизованы.
        emit(AuthAuthenticated(user: savedUser));
      } else {
        // Если не валиден, пробуем обновить
        final newToken = await _authService.refreshToken();
        if (newToken != null && savedUser != null) {
          emit(AuthAuthenticated(user: savedUser));
        } else {
          emit(AuthUnauthenticated());
        }
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Вход в систему
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(username, password);
      // После успешного входа
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
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
