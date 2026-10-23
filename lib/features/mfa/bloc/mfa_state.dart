import 'package:equatable/equatable.dart';
import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';

enum MfaStatus { init, setup, ready, verify }

class MfaState extends Equatable {
  final MfaStatus status;
  final Object? error;
  final bool isLoading;
  final Challenge? challenge;
  final DateTime? lastRefresh;
  final Challenge? lastGrantedChallenge;

  const MfaState({
    this.status = MfaStatus.init,
    this.error,
    this.isLoading = false,
    this.challenge,
    this.lastRefresh,
    this.lastGrantedChallenge,
  });

  MfaState copyWith({
    MfaStatus? status,
    Object? error,
    bool? isLoading,
    Challenge? challenge,
    DateTime? lastRefresh,
    Challenge? lastGrantedChallenge,
  }) {
    return MfaState(
      status: status ?? this.status,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      challenge: challenge ?? this.challenge,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      lastGrantedChallenge: lastGrantedChallenge ?? this.lastGrantedChallenge,
    );
  }

  @override
  List<Object?> get props => [status, error, isLoading, challenge, lastRefresh];
}
