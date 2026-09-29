import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';

/// The reduced person view guests get instead of a full profile.
///
/// The rule in this concept: guests see people only within a shared context,
/// and reduced even there — either without a profile link or with a reduced
/// view. This is that reduced view, built once and used in the
/// places the rule allows: the guest's own team, and the contact people of
/// their Gliederung.
///
/// What it deliberately does not carry: memberships, roles, achievements, tags,
/// Personen-Nr., or any contact detail that was not designated as a contact
/// option. Those are what "vollständiges Mitgliedsprofil" means, and they are
/// exactly what the rule withholds.
class PersonEntry {
  const PersonEntry({required this.name, this.position, this.division, this.isGuest = false, this.contact});

  final String name;

  /// Role in this context — "Teamleitung", "Kreisvorstand". Shown for contact
  /// people, where knowing whom to ask is the entire point.
  final String? position;

  final String? division;

  /// Guests are marked wherever they appear, including to other guests.
  final bool isGuest;

  /// Only the designated contact option, never the full phone list.
  final String? contact;
}

/// One row. Tapping opens the reduced view rather than a profile.
class PersonTile extends StatelessWidget {
  const PersonTile({super.key, required this.person, this.withDetail = true});

  final PersonEntry person;

  /// False renders the row without any tap target at all — the other half of
  /// "either … or", for contexts where even a reduced view is more
  /// than a guest needs.
  final bool withDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: ThemeColors.grey200,
            child: Text(person.name.isEmpty ? '?' : person.name.characters.first, style: theme.textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(person.name, style: theme.textTheme.bodyLarge)),
                    if (person.isGuest) ...[const SizedBox(width: 8), GuestBadge()],
                  ],
                ),
                if (person.position != null || person.division != null)
                  Text(
                    [person.position, person.division].whereType<String>().join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (withDetail) Icon(Icons.chevron_right, color: theme.disabledColor),
        ],
      ),
    );

    if (!withDetail) return Container(color: theme.colorScheme.surface, child: row);

    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(onTap: () => showReducedPerson(context, person), child: row),
    );
  }
}

/// The badge itself. Kept as its own widget because it appears in member-facing
/// lists too — guests are marked wherever they show up, not only here.
class GuestBadge extends StatelessWidget {
  // Not const: the label comes from the runtime wording choice, so the widget
  // has to rebuild when that changes.
  // ignore: prefer_const_constructors_in_immutables
  GuestBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: ThemeColors.grey200, borderRadius: BorderRadius.circular(10)),
      child: Text(terms.badge, style: theme.textTheme.bodySmall?.apply(color: ThemeColors.text)),
    );
  }
}

/// Reduced detail. A sheet rather than a screen: it is small, read-only and has
/// no actions beyond the contact option, which is what sheets are for in this
/// app.
Future<void> showReducedPerson(BuildContext context, PersonEntry person) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) {
      final theme = Theme.of(sheet);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: ThemeColors.grey200,
                    child: Text(
                      person.name.isEmpty ? '?' : person.name.characters.first,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person.name, style: theme.textTheme.titleLarge),
                        if (person.position != null) Text(person.position!, style: theme.textTheme.bodyMedium),
                        if (person.division != null) Text(person.division!, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (person.isGuest) GuestBadge(),
                ],
              ),
              if (person.contact != null) ...[
                const SizedBox(height: 20),
                Text('Kontakt', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(person.contact!, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                color: ThemeColors.grey100,
                child: Text('Mehr Angaben sind Mitgliedern vorbehalten.', style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
      );
    },
  );
}
