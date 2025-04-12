import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/constants/secure_storage_keys.dart';
import 'package:gruene_app/app/services/fcm_topic_service.dart';

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
  final FcmTopicService _fcmTopicService = GetIt.instance<FcmTopicService>();
  final _secureStorage = GetIt.instance<FlutterSecureStorage>();

  Stream<AuthState> get authStateStream => stream;

  AuthBloc(this.authRepository) : super(AuthLoading()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final success = await authRepository.login();
      if (success) {
        emit(Authenticated());
        _enableDefaultPushNotifications();
      } else {
        emit(Unauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _fcmTopicService.unsubscribeFromAllTopics();
      await authRepository.logout();
      emit(Unauthenticated());
    });

    on<CheckTokenRequested>((event, emit) async {
      emit(AuthLoading());
      final isValid = await authRepository.isTokenValid();
      if (isValid) {
        emit(Authenticated());
        _triggerTopicUpdates();
      } else {
        final refreshed = await authRepository.refreshToken();
        if (refreshed) {
          emit(Authenticated());
          _triggerTopicUpdates();
        } else {
          emit(Unauthenticated());
        }
      }
    });
  }

  Future<void> _enableDefaultPushNotifications() async {
    await _secureStorage.write(key: SecureStorageKeys.pushNotificationsBV, value: 'true');
    await _secureStorage.write(key: SecureStorageKeys.pushNotificationsLV, value: 'true');
    await _secureStorage.write(key: SecureStorageKeys.pushNotificationsKV, value: 'true');

    await _triggerTopicUpdates();
  }

  Future<void> _triggerTopicUpdates() async {
    if (state is Authenticated) {
      await _fcmTopicService.updateSubscriptions();
    }
  }
}
