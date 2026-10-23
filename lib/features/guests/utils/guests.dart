import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

extension GuestStatusExtension on GuestStatus {
  String get label => switch (this) {
    GuestStatus.active => t.guests.guestStatusLabel.active,
    GuestStatus.blocked => t.guests.guestStatusLabel.blocked,
    GuestStatus.expired => t.guests.guestStatusLabel.expired,
    GuestStatus.swaggerGeneratedUnknown => t.common.unknown,
  };
}

extension GuestHistoryTypeExtension on GuestHistoryType {
  String get label => switch (this) {
    GuestHistoryType.invited => t.guests.historyLabel.invited,
    GuestHistoryType.accepted => t.guests.historyLabel.accepted,
    GuestHistoryType.renewed => t.guests.historyLabel.renewed,
    GuestHistoryType.expired => t.guests.historyLabel.expired,
    GuestHistoryType.blocked => t.guests.historyLabel.blocked,
    GuestHistoryType.unblocked => t.guests.historyLabel.unblocked,
    GuestHistoryType.swaggerGeneratedUnknown => t.common.unknown,
  };
}

extension GuestExtension on Guest {
  String get fullName => '$firstName $lastName';

  bool matches(String query) {
    final term = query.trim().toLowerCase();
    return term.isEmpty || fullName.toLowerCase().contains(term) || (email?.toLowerCase().contains(term) ?? false);
  }
}

extension GuestDetailExtension on GuestDetail {
  String get fullName => '$firstName $lastName';

  Guest toGuest() => Guest(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    divisionKey: divisionKey,
    status: status,
    expiresOn: expiresOn,
  );
}
