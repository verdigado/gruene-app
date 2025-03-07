import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/features/mfa/dtos/login_attempt_dto.dart';
import 'package:keycloak_authenticator/api.dart';

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
      emit(
        state.copyWith(
          status: _authenticator != null ? MfaStatus.ready : MfaStatus.setup,
          error: null,
          loginAttempt: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          error: error,
          loginAttempt: null,
        ),
      );
    }
  }

  Future<void> _onSetupMfa(SetupMfa event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.setup || state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      _authenticator = await _service.create(event.activationToken);
      emit(
        state.copyWith(
          status: MfaStatus.ready,
          isLoading: false,
          loginAttempt: null,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          error: err.toString(),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onDeleteMfa(DeleteMfa event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.ready || _authenticator == null) return;
    try {
      await _service.delete(_authenticator!);
      emit(
        state.copyWith(
          status: MfaStatus.setup,
          loginAttempt: null,
          lastRefresh: null,
        ),
      );
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onRefreshMfa(RefreshMfa event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.ready || state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      var challenge = await _authenticator!.fetchChallenge();
      if (challenge != null) {
        emit(
          state.copyWith(
            loginAttempt: LoginAttemptDto(
              browser: challenge.browser,
              ipAddress: challenge.ipAddress,
              loggedInAt: DateTime.fromMillisecondsSinceEpoch(challenge.updatedTimestamp),
              os: challenge.os,
              challenge: challenge,
              expiresIn: challenge.expiresIn ?? 60,
              clientName: challenge.clientName,
            ),
            status: MfaStatus.verify,
            lastRefresh: DateTime.now(),
            isLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            lastRefresh: DateTime.now(),
          ),
        );
      }
    } on KeycloakClientException catch (err) {
      if (err.type == KeycloakExceptionType.notRegistered) {
        try {
          await _service.delete(_authenticator!);
          _authenticator = null;
          emit(state.copyWith(status: MfaStatus.setup));
        } catch (_) {}
      }
      emit(
        state.copyWith(
          error: err.toString(),
          loginAttempt: null,
          isLoading: false,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          error: err.toString(),
          loginAttempt: null,
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onSendReply(SendReply event, Emitter<MfaState> emit) async {
    if (state.status != MfaStatus.verify || state.loginAttempt == null || state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _authenticator!.reply(
        challenge: state.loginAttempt!.challenge,
        granted: event.granted,
      );
      emit(
        state.copyWith(
          status: MfaStatus.ready,
          loginAttempt: null,
          isLoading: false,
          lastGrantedLoginAttempt: event.granted ? state.loginAttempt : null,
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(
          status: MfaStatus.ready,
          error: err.toString(),
          isLoading: false,
        ),
      );
    }
  }

  void _onIdleTimeout(IdleTimeout event, Emitter<MfaState> emit) {
    if (state.status != MfaStatus.verify || state.loginAttempt == null || state.isLoading) return;
    emit(
      state.copyWith(
        status: MfaStatus.ready,
        loginAttempt: null,
      ),
    );
  }
}
