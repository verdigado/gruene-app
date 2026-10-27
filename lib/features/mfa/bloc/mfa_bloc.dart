import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';

class MfaBloc extends Bloc<MfaEvent, MfaState> {
  final AuthenticatorService _service = GetIt.I<AuthenticatorService>();
  Authenticator? _authenticator;

  MfaBloc() : super(const MfaState()) {
    on<InitMfa>(_onInitMfa);
    on<SetupMfa>(_onSetupMfa);
    on<DeleteMfa>(_onDeleteMfa);
    on<RefreshMfa>(_onRefreshMfa);
    on<SendReply>(_onSendReply);
    on<IdleTimeout>(_onIdleTimeout);
  }

  Future<void> _onInitMfa(InitMfa event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.init) return;
    try {
      _authenticator = await _service.getFirst();

      final firebaseToken = await FirebaseMessaging.instance.getToken();
      await _updateDevicePushId(firebaseToken);

      FirebaseMessaging.instance.onTokenRefresh.listen(_updateDevicePushId);

      emit(
        state.copyWith(
          status: _authenticator != null ? MfaStatus.ready : MfaStatus.setup,
          error: null,
          challenge: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(error: error, challenge: null));
    }
  }

  Future<void> _onSetupMfa(SetupMfa event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.setup || state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      String? firebaseToken = await FirebaseMessaging.instance.getToken();
      _authenticator = await _service.create(event.activationToken, devicePushId: firebaseToken);
      emit(state.copyWith(status: MfaStatus.ready, isLoading: false, challenge: null));
    } catch (error) {
      emit(state.copyWith(error: error, isLoading: false));
    }
  }

  Future<void> _onDeleteMfa(DeleteMfa event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.ready || _authenticator == null) return;
    try {
      await _service.delete(_authenticator!);
      emit(state.copyWith(status: MfaStatus.setup, challenge: null, lastRefresh: null));
    } catch (error) {
      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onRefreshMfa(RefreshMfa event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.ready || state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final challenge = await _authenticator!.fetchChallenge();
      if (challenge != null) {
        emit(
          state.copyWith(challenge: challenge, status: MfaStatus.verify, lastRefresh: DateTime.now(), isLoading: false),
        );
      } else {
        emit(state.copyWith(isLoading: false, lastRefresh: DateTime.now()));
      }
    } on KeycloakClientException catch (error) {
      if (error.type == KeycloakExceptionType.notRegistered) {
        try {
          await _service.delete(_authenticator!);
          _authenticator = null;
          emit(state.copyWith(status: MfaStatus.setup));
        } catch (_) {}
      }
      emit(state.copyWith(error: event.raiseError ? error : null, challenge: null, isLoading: false));
    } catch (error) {
      emit(state.copyWith(error: event.raiseError ? error : null, challenge: null, isLoading: false));
    }
  }

  Future<void> _onSendReply(SendReply event, Emitter<MfaState> emit) async {
    final challenge = state.challenge;
    if (state.status != MfaStatus.verify || challenge == null || state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _authenticator!.reply(challenge: challenge, granted: event.granted);
      emit(
        state.copyWith(
          status: MfaStatus.ready,
          challenge: null,
          isLoading: false,
          lastGrantedChallenge: event.granted ? challenge : null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: MfaStatus.ready, error: error, isLoading: false));
    }
  }

  void _onIdleTimeout(IdleTimeout event, Emitter<MfaState> emit) {
    if (state.status != MfaStatus.verify || state.challenge == null || state.isLoading) return;
    emit(state.copyWith(status: MfaStatus.ready, challenge: null));
  }

  Future<void> _updateDevicePushId(String? devicePushId) async {
    try {
      await _authenticator?.updateDevicePushId(devicePushId: devicePushId);
    } on KeycloakClientException catch (error) {
      if (error.type == KeycloakExceptionType.notRegistered) {
        // The authenticator is not registered and will be removed anyway
        // Therefore, we can just fail silently
        return;
      }
      if (error.type == KeycloakExceptionType.networkError) {
        return;
      }
      rethrow;
    }
  }
}
