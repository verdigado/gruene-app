import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/prototype/flows/guest/reduced_person.dart';

/// The three person-views a guest gets, in one place so the pattern can be
/// judged as a set rather than screen by screen.
///
/// The rule in this concept: shared context decides. Own team yes,
/// contact people of the Gliederung yes, the ranking of every challenge no —
/// and never the full profile.
class GuestPersonViewsScreen extends StatelessWidget {
  const GuestPersonViewsScreen({super.key});

  static const _team = [
    PersonEntry(name: 'Bea Koordination', position: 'Teamleitung', division: 'KV Berlin-Mitte'),
    PersonEntry(name: 'Anke Mitglied', division: 'KV Berlin-Mitte'),
    PersonEntry(name: 'Dana Weber', division: 'KV Berlin-Mitte', isGuest: true),
    PersonEntry(name: 'Jonas Schmitt', division: 'LV Berlin', isGuest: true),
  ];

  static const _contacts = [
    PersonEntry(
      name: 'Bea Koordination',
      position: 'Wahlkampfkoordination',
      division: 'KV Berlin-Mitte',
      contact: 'wahlkampf@example.org',
    ),
    PersonEntry(
      name: 'Frank Landesbüro',
      position: 'Geschäftsführung',
      division: 'KV Berlin-Mitte',
      contact: 'buero@example.org',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MainAppBar(title: 'Personen als Gast'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Section(
            title: 'Mein Team',
            explanation:
                'Klarnamen, weil die Zusammenarbeit sie braucht. Antippen zeigt '
                'die reduzierte Ansicht, nicht das Mitgliedsprofil.',
            kind: Column(children: [for (final p in _team) PersonTile(person: p)]),
          ),
          _Section(
            title: 'Kontaktpersonen im KV',
            explanation:
                'Gäste sind einer Gliederung zugeordnet und müssen wissen, an '
                'wen sie sich wenden können — Name, Funktion, Kontaktweg.',
            kind: Column(children: [for (final p in _contacts) PersonTile(person: p)]),
          ),
          _Section(
            title: 'Challenge-Rangliste',
            explanation:
                'Hier reicht der geteilte Kontext nicht: die Top 99 aller '
                'Challenges sind keine Personen, mit denen der Gast zusammen '
                'arbeitet. Darum Anzeigename statt Klarname.',
            kind: Column(
              children: [
                _LeaderboardRow(rank: 1, name: 'AnkeM', points: 148),
                _LeaderboardRow(rank: 2, name: 'JonasS', points: 131),
                _LeaderboardRow(rank: 3, name: 'DanaW', points: 96, isGuest: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              '[Prototyp] Die Rangliste nutzt bereits ein Feld '
              '`ChallengeLeaderboardEntry.userName` — einen String, keinen Vor-/'
              'Nachnamen. Offen ist nur, womit die API es füllt.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.explanation, required this.kind});

  final String title;
  final String explanation;
  final Widget kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Text(explanation, style: theme.textTheme.bodySmall),
        ),
        kind,
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.rank, required this.name, required this.points, this.isGuest = false});

  final int rank;
  final String name;
  final int points;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('$rank.', style: theme.textTheme.bodyLarge)),
          Expanded(
            child: Row(
              children: [
                Text(name, style: theme.textTheme.bodyLarge),
                if (isGuest) ...[const SizedBox(width: 8), GuestBadge()],
              ],
            ),
          ),
          Text('$points', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
