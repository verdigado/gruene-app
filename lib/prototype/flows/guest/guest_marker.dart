import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_detail.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/flows/guest/reduced_person.dart';
import 'package:gruene_app/prototype/prototype.dart';
import 'package:gruene_app/prototype/settings.dart';

/// How guests appear to members — the other direction of `reduced_person.dart`.
///
/// `reduced_person.dart` answers what a guest sees of people. This answers
/// what a member sees of a guest: in the member search, in team member lists,
/// in the challenge leaderboard. Both directions use the same badge, because a
/// guest is a guest to everyone; what differs is how much else is shown.
///
/// Marking and filtering are separate switches on purpose. A badge says
/// "colleague, with a note". A filter says "category you sort people by".
/// Those are different statements about what a guest is, so each can be
/// shown on its own.

/// Guests are named as guests wherever they appear.
final guestLabeling = PrototypeToggle(
  id: 'guest.labeling',
  label: 'Gäste kennzeichnen',
  description: 'Badge "Gast" in Mitgliedersuche, Teamlisten und Challenge-Rangliste.',
  defaultOn: true,
);

/// The dedicated filter in the member search.
///
/// Off by default: the badge alone is the smaller claim, and the demo should
/// start there. Switching this on mid-conversation is the question itself.
final guestSearchFilter = PrototypeToggle(
  id: 'guest.search_filter',
  label: 'Filter "Gäste" in der Suche',
  description: 'Zusätzlicher Filter in der Mitgliedersuche: alle, nur Mitglieder, nur Gäste.',
  defaultOn: false,
);

/// What the member search may be narrowed to.
enum GuestFilterValue {
  all('Alle'),
  withoutGuests('Nur Mitglieder'),
  onlyGuests('Nur Gäste');

  const GuestFilterValue(this.label);
  final String label;
}

/// The user id a guest would have.
///
/// PROTOTYPE ONLY. The real app cannot derive this — `PublicProfile` carries no
/// flag saying an account is a guest, and `ChallengeLeaderboardEntry` carries
/// no user id at all. Both need a field before any of this can be built for
/// real.
String guestUserId(GuestEntry entry) => 'gast-${_slug(entry.displayName)}';

String _slug(String name) => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

bool isGuestUser(String? userId) => userId != null && userId.startsWith('gast-');

/// For the places that only have a display name to go on — the leaderboard and
/// the team statistics.
///
/// Deliberately not restricted to current guests. A closed challenge still
/// lists whoever took part, and someone whose access has ended was never a
/// member — dropping the badge there would quietly promote them in the record.
bool isGuestName(String? name) => name != null && guestEntries.value.any((e) => e.name == name);

/// The record behind a guest account, so member-facing views can say when the
/// access ends. Same records the coordinator screens work on, so extending a
/// guest in Gastzugänge changes what the member search shows.
GuestEntry? guestToUser(String? userId) {
  if (!isGuestUser(userId)) return null;
  for (final entry in guestEntries.value) {
    if (guestUserId(entry) == userId) return entry;
  }
  return null;
}

/// The badge, where a member-facing list shows a name.
///
/// Renders nothing when the flow is off, or when the person is not a guest —
/// so call sites stay a single unconditional widget in the row.
class GuestMarker extends StatelessWidget {
  const GuestMarker.forUser(String? userId, {super.key}) : _isGuest = null, _userId = userId, _name = null;

  const GuestMarker.forName(String? name, {super.key}) : _isGuest = null, _userId = null, _name = name;

  const GuestMarker.ifGuest(bool isGuest, {super.key}) : _isGuest = isGuest, _userId = null, _name = null;

  final bool? _isGuest;
  final String? _userId;
  final String? _name;

  bool get _applies => _isGuest ?? (_userId != null ? isGuestUser(_userId) : isGuestName(_name));

  @override
  Widget build(BuildContext context) {
    if (!guestLabeling.isOn || !_applies) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(left: 8), child: GuestBadge());
  }
}

/// What a member sees on a guest's profile page.
///
/// A guest's profile is mostly empty — no memberships, no roles, no
/// achievements — and an empty member profile reads as a broken one. This says
/// what it actually is, and how long it lasts.
class GuestInfoCard extends StatelessWidget {
  const GuestInfoCard.forUser(this.userId, {super.key});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final entry = guestToUser(userId);
    if (!guestLabeling.isOn || entry == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final daysLeft = entry.daysLeft;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ThemeColors.grey100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(terms.access, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (entry.expiryDate != null)
            Text(
              daysLeft != null && daysLeft <= 14
                  ? 'Läuft in $daysLeft Tagen ab — ${shortDate(entry.expiryDate!)}'
                  : 'Befristet bis ${shortDate(entry.expiryDate!)}',
              style: theme.textTheme.bodyMedium?.apply(
                color: daysLeft != null && daysLeft <= 14 ? theme.colorScheme.error : null,
              ),
            ),
          Text('Eingeladen von ${entry.invitedBy} · ${entry.division}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// The way from a guest's profile into their access record, at the bottom of
/// the profile like the other actions on a person (e.g. leaving a team).
///
/// Found the person, so act on them here rather than sending someone back to
/// a list they already came out of. Permission is per Gliederung: a
/// coordinator finds guests of other Gliederungen in the party-wide search but
/// may not act on them, and is told so instead of seeing a dead end.
class GuestManageAction extends StatelessWidget {
  const GuestManageAction.forUser(this.userId, {super.key});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final entry = guestToUser(userId);
    final persona = prototypePersona.value;
    if (!guestLabeling.isOn || entry == null || !persona.canInviteGuests) return const SizedBox.shrink();

    if (persona.canManage(entry.division)) {
      return TextListItem(
        title: '${terms.access} verwalten',
        onPress: () =>
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GuestDetailScreen(entry: entry))),
      );
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Verlängern oder sperren kann nur die Koordination in ${entry.division}.',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
