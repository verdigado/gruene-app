import 'package:equatable/equatable.dart';
import 'package:gruene_app/features/mfa/dtos/login_attempt_dto.dart';

enum MfaStatus { init, setup, ready, verify }

class MfaState extends Equatable {
  final MfaStatus status;
  final Object? error;
  final bool isLoading;
  final LoginAttemptDto? loginAttempt;
  final DateTime? lastRefresh;
  final LoginAttemptDto? lastGrantedLoginAttempt;

  const MfaState({
    this.status = MfaStatus.init,
    this.error,
    this.isLoading = false,
    this.loginAttempt,
    this.lastRefresh,
    this.lastGrantedLoginAttempt,
  });

  MfaState copyWith({
    MfaStatus? status,
    Object? error,
    bool? isLoading,
    LoginAttemptDto? loginAttempt,
    DateTime? lastRefresh,
    LoginAttemptDto? lastGrantedLoginAttempt,
  }) {
    return MfaState(
      status: status ?? this.status,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      loginAttempt: loginAttempt ?? this.loginAttempt,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      lastGrantedLoginAttempt: lastGrantedLoginAttempt ?? this.lastGrantedLoginAttempt,
    );
  }

  @override
  List<Object?> get props => [status, error, isLoading, loginAttempt, lastRefresh];
}
