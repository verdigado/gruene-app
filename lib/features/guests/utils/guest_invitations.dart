import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/utils/error.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension GuestInvitationStatusExtension on GuestInvitationStatus {
  String get label => switch (this) {
    GuestInvitationStatus.open => t.guests.statusLabel.open,
    GuestInvitationStatus.accepted => t.guests.statusLabel.accepted,
    GuestInvitationStatus.expired => t.guests.statusLabel.expired,
    GuestInvitationStatus.revoked => t.guests.statusLabel.revoked,
    GuestInvitationStatus.swaggerGeneratedUnknown => t.common.unknown,
  };
}

/// Messages for expected API answers, by status code. Anything else gets a neutral message, so the inviter learns
/// nothing about the invited person.
String guestErrorMessage(Object error, {Map<int, String> byStatusCode = const {}}) {
  final message = error is ApiException ? byStatusCode[error.statusCode] : null;
  return message ?? getErrorMessage(error, defaultMessage: t.guests.error.failed);
}
