import 'package:gruene_app/prototype/settings.dart';

/// The words the flow uses for a non-member with time-limited access.
///
/// Switchable at runtime because the naming is a product question, not a
/// styling one: "Gast" is passive and says *not one of us*, which is exactly
/// the wrong frame for a ladder into membership. The alternative splits the
/// two — a warm word for people, a factual word for the access
/// and for the badge, since the badge's job is to set expectations about what
/// someone can see, and a warm word cannot do that job.
///
/// Two variants only. A third would make the demo a vocabulary exercise
/// instead of a comparison of two positions.
enum GuestNaming {
  guest(
    label: 'Gast — heutiger Stand',
    badge: 'Gast',
    person: 'Gast',
    plural: 'Gäste',
    access: 'Gastzugang',
    accesses: 'Gastzugänge',
    invite: 'Gast einladen',
    invitations: 'Gast-Einladungen',
  ),
  supporter(
    label: 'Unterstützende — Person warm, Zugang sachlich',
    badge: 'befristet',
    person: 'Unterstützende',
    plural: 'Unterstützende',
    access: 'Befristeter Zugang',
    accesses: 'Befristete Zugänge',
    invite: 'Unterstützende einladen',
    invitations: 'Einladungen',
  );

  const GuestNaming({
    required this.label,
    required this.badge,
    required this.person,
    required this.plural,
    required this.access,
    required this.accesses,
    required this.invite,
    required this.invitations,
  });

  /// How the variant is described in the settings view.
  final String label;

  /// Next to a name in a member-facing list. Short on purpose.
  final String badge;

  final String person;
  final String plural;

  /// The access as a thing: what is granted, extended, expires.
  final String access;

  /// Section title for the administration list.
  final String accesses;

  /// The invitation entry point.
  final String invite;

  final String invitations;
}

final guestNaming = PrototypeChoice<GuestNaming>(
  id: 'guest.naming',
  label: 'Benennung',
  description: 'Wie die App Nicht-Mitglieder mit befristetem Zugang benennt.',
  values: GuestNaming.values,
  labelOf: (v) => v.label,
  defaultValue: GuestNaming.guest,
);

/// Shorthand, so call sites read as text rather than as lookups.
GuestNaming get terms => guestNaming.value;
