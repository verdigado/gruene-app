import 'package:equatable/equatable.dart';

abstract class MfaEvent extends Equatable {
  const MfaEvent();

  @override
  List<Object?> get props => [];
}

class InitMfa extends MfaEvent {}

class SetupMfa extends MfaEvent {
  final String activationToken;

  const SetupMfa(this.activationToken);

  @override
  List<Object?> get props => [activationToken];
}

class DeleteMfa extends MfaEvent {}

class RefreshMfa extends MfaEvent {
  final bool raiseError;

  const RefreshMfa({this.raiseError = true});
}

class SendReply extends MfaEvent {
  final bool granted;

  const SendReply(this.granted);

  @override
  List<Object?> get props => [granted];
}

class IdleTimeout extends MfaEvent {}
