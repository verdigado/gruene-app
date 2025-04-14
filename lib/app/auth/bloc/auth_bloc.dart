import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/services/push_notification_service.dart';

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
  final PushNotificationService _pushNotificationService = GetIt.instance<PushNotificationService>();

  Stream<AuthState> get authStateStream => stream;

  AuthBloc(this.authRepository) : super(AuthLoading()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final success = await authRepository.login();
      if (success) {
        emit(Authenticated());
        await _pushNotificationService.updateSubscriptions();
      } else {
        emit(Unauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authRepository.logout();
      await _pushNotificationService.updateSubscriptions();
      emit(Unauthenticated());
    });

    on<CheckTokenRequested>((event, emit) async {
      emit(AuthLoading());
      final isValid = await authRepository.isTokenValid();
      if (isValid) {
        emit(Authenticated());
      } else {
        final refreshed = await authRepository.refreshToken();
        await _pushNotificationService.updateSubscriptions();
        if (refreshed) {
          emit(Authenticated());
        } else {
          emit(Unauthenticated());
        }
      }
    });
  }
}
