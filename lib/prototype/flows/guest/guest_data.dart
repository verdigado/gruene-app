import 'package:flutter/foundation.dart';
import 'package:gruene_app/prototype/prototype.dart';
import 'package:gruene_app/prototype/settings.dart';

/// Prototype-local state for the guest flows. No backend, no persistence —
/// enough that the screens actually react to each other.

/// The only three states the invitation list shows.
/// There is deliberately no failure state: "abgelehnt, weil bereits Mitglied"
/// would leak party membership, which is a special category of personal data.
enum GuestStatus {
  pending('Offen'),
  accepted('Angenommen'),
  expired('Abgelaufen');

  const GuestStatus(this.label);
  final String label;
}

/// One entry in a guest's access history. Kept as a list rather than a single
/// "extended at" field on purpose: a renewal should keep the history of who
/// extended an access and when.
class GuestEvent {
  const GuestEvent({required this.timestamp, required this.what, this.by});

  final DateTime timestamp;
  final String what;
  final String? by;
}

class GuestEntry {
  GuestEntry({
    required this.email,
    required this.division,
    required this.status,
    this.name,
    this.expiryDate,
    this.invitedBy = 'Bea Koordination',
    this.extensions = 0,
    DateTime? invitedAt,
    this.acceptedAt,
    this.invitationExpiresAt,
    this.teams = const [],
    List<GuestEvent>? history,
  }) : invitedAt = invitedAt ?? DateTime.now(),
       history = history ?? [];

  final String email;
  final String division;
  final String invitedBy;
  GuestStatus status;
  String? name;

  /// Would come from the server. The app never computes it.
  DateTime? expiryDate;

  /// How often the access was renewed. History only — in this concept renewals
  /// are unlimited: a cap makes people drop out without understanding why,
  /// and they come back as duplicates.
  int extensions;

  final DateTime invitedAt;
  DateTime? acceptedAt;

  /// An open invitation has its own clock — the activation code is time-limited
  /// and expires long before the guest access would.
  DateTime? invitationExpiresAt;

  /// Set when the person says they have applied for membership.
  ///
  /// Self-declared, because the application can be filled anywhere — gruene.de,
  /// a QR code on a flyer — and the app would never see it. Unverified is fine
  /// for what it is used for: not slamming a door, and giving a reason to
  /// extend. It is never used to merge records.
  DateTime? applicationSubmittedAt;

  bool get applicationPending => applicationSubmittedAt != null;

  List<String> teams;
  final List<GuestEvent> history;

  /// Standard duration of a guest access, and of each renewal, in this concept.
  static const duration = Duration(days: 90);

  /// Renews by the standard duration, counted from today but never shortening
  /// an access that still has more time left than that.
  void extend({required String by}) {
    final extended = DateTime.now().add(duration);
    if (expiryDate == null || extended.isAfter(expiryDate!)) expiryDate = extended;
    extensions++;
    logEvent('Zugang verlaengert', by: by);
  }

  String get displayName => name ?? email;

  /// Days left, from the date the server supplied. Never computed from "90".
  int? get daysLeft => expiryDate?.difference(DateTime.now()).inDays;

  void logEvent(String what, {String? by}) => history.add(GuestEvent(timestamp: DateTime.now(), what: what, by: by));
}

DateTime _daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

final guestEntries = ValueNotifier<List<GuestEntry>>([
  GuestEntry(
    email: 'dana.weber@example.org',
    name: 'Dana Weber',
    division: 'KV Berlin-Mitte',
    status: GuestStatus.accepted,
    expiryDate: DateTime.now().add(const Duration(days: 62)),
    invitedAt: _daysAgo(28),
    acceptedAt: _daysAgo(27),
    teams: const ['Haustuer Mitte Nord'],
    history: [
      GuestEvent(timestamp: _daysAgo(28), what: 'Eingeladen', by: 'Bea Koordination'),
      GuestEvent(timestamp: _daysAgo(27), what: 'Einladung angenommen'),
      GuestEvent(timestamp: _daysAgo(2), what: 'Zu Team hinzugefuegt', by: 'Bea Koordination'),
    ],
  ),
  GuestEntry(
    // No name: the invitation form only takes an email address. The name comes
    // from the invitee when they accept, so an open invitation shows the address.
    email: 'cem.yilmaz@example.org',
    division: 'KV Berlin-Mitte',
    status: GuestStatus.pending,
    invitedAt: _daysAgo(3),
    invitationExpiresAt: DateTime.now().add(const Duration(days: 4)),
    history: [GuestEvent(timestamp: _daysAgo(3), what: 'Eingeladen', by: 'Bea Koordination')],
  ),
  GuestEntry(
    email: 'j.schmitt@example.org',
    name: 'Jonas Schmitt',
    division: 'LV Berlin',
    status: GuestStatus.accepted,
    expiryDate: DateTime.now().add(const Duration(days: 9)),
    extensions: 2,
    invitedAt: _daysAgo(171),
    acceptedAt: _daysAgo(170),
    teams: const ['Plakate LV', 'Haustuer Prenzlauer Berg'],
    history: [
      GuestEvent(timestamp: _daysAgo(171), what: 'Eingeladen', by: 'Bea Koordination'),
      GuestEvent(timestamp: _daysAgo(170), what: 'Einladung angenommen'),
      GuestEvent(timestamp: _daysAgo(90), what: 'Zugang verlaengert', by: 'Bea Koordination'),
      GuestEvent(timestamp: _daysAgo(20), what: 'Zugang verlaengert', by: 'Frank Landesbuero'),
    ],
  ),
  GuestEntry(
    email: 'alt.helfer@example.org',
    name: 'Erik Lang',
    division: 'KV Berlin-Pankow',
    status: GuestStatus.expired,
    invitedAt: _daysAgo(200),
    acceptedAt: _daysAgo(198),
    history: [
      GuestEvent(timestamp: _daysAgo(200), what: 'Eingeladen', by: 'Bea Koordination'),
      GuestEvent(timestamp: _daysAgo(198), what: 'Einladung angenommen'),
      GuestEvent(timestamp: _daysAgo(108), what: 'Zugang abgelaufen'),
    ],
  ),
]);

/// The record behind the currently simulated guest.
///
/// Keyed off the persona rather than hard-coded, because the offboarding
/// screens need a guest who is about to expire and one who already has.
GuestEntry? ownAccess() {
  final name = prototypePersona.value.guestName;
  if (name == null) return null;
  for (final e in guestEntries.value) {
    if (e.name == name) return e;
  }
  return null;
}

void addGuest(GuestEntry entry) => guestEntries.value = [entry, ...guestEntries.value];

void updateGuest() => guestEntries.value = List.of(guestEntries.value);

void removeGuest(GuestEntry entry) => guestEntries.value = guestEntries.value.where((e) => e != entry).toList();

String shortDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Which two-factor design the invitee flow demonstrates.
///
/// The difference is not polish, it is a capability: whether the app can
/// receive the Keycloak action token from the same session, or whether a human
/// has to ferry it across a context switch. Which of these is buildable is a
/// technical question this prototype does not answer.
enum TwoFactorVariant {
  /// The app registers itself. One tap.
  optimistic('Optimistisch — App registriert sich selbst'),

  /// What the app does today: Keycloak page, copy the action token URL,
  /// switch context, paste it.
  realistic('Realistisch — Link kopieren und einfügen');

  const TwoFactorVariant(this.label);
  final String label;
}

/// Registered as a prototype setting, so the variant can be switched mid-demo
/// from the settings view rather than only in code.
final twoFactorVariant = PrototypeChoice<TwoFactorVariant>(
  id: 'guest.two_factor',
  label: 'Zwei-Faktor-Variante',
  description: 'Technisch offen: kann die App den Action-Token selbst entgegennehmen?',
  values: TwoFactorVariant.values,
  labelOf: (v) => v.label,
  defaultValue: TwoFactorVariant.optimistic,
);

/// Stands in for the Keycloak action token URL that has to reach the app.
/// Long on purpose — the length is the problem.
const actionTokenUrl =
    'https://saml.gruene.de/realms/gruenes-netz/login-actions/action-token'
    '?key=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3OTQyMzAwMDAsInN1YiI6'
    'IjEwMDA0IiwiYWN0IjoiYXV0aGVudGljYXRvci1yZWdpc3RlciJ9.8xQmR2vK4pN7wZ3aL1'
    '&client_id=gruene_app&tab_id=A7mQ2pL9xR0';
