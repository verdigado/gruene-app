import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gruene_app/app/auth/repository/auth_repository.dart';

class AuthEvent {}

class LoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class CheckTokenRequested extends AuthEvent {}

class AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  Stream<AuthState> get authStateStream => stream;

  AuthBloc(this.authRepository) : super(AuthLoading()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final success = await authRepository.login();
      if (success) {
        emit(Authenticated());
      } else {
        emit(Unauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authRepository.logout();
      emit(Unauthenticated());
    });

    on<CheckTokenRequested>((event, emit) async {
      emit(AuthLoading());
      final isValid = await authRepository.isTokenValid();
      if (isValid) {
        emit(Authenticated());
      } else {
        final refreshed = await authRepository.refreshToken();
        if (refreshed) {
          emit(Authenticated());
        } else {
          emit(Unauthenticated());
        }
      }
    });
  }
}
