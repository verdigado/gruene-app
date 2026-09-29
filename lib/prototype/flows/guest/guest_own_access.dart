import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/prototype/fixtures/challenges.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_flow.dart';
import 'package:gruene_app/prototype/flows/guest/guest_membership.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// What a guest sees in the Mitglieder tab instead of the members area.
///
/// The counterpart to GuestDetailScreen: otherwise a coordinator knows more
/// about someone's access than that person does, which is the kind of asymmetry
/// that reads badly in a data-protection review.
///
/// This deliberately splits the tab rather than hiding it. The section mixes
/// "my own data" with "other people's data", and those have opposite answers
/// for a guest — the member directory and search stay gone, the person's own
/// record does not.
class GuestOwnAccessScreen extends StatelessWidget {
  const GuestOwnAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final access = ownAccess();
    final daysLeft = access?.daysLeft;
    final expiresSoon = guestOffboarding.isOn && daysLeft != null && daysLeft <= 14;

    return Scaffold(
      appBar: MainAppBar(title: 'Mein Zugang'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (expiresSoon) _ExpiryBanner(access: access!),
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: ThemeColors.grey200,
                  child: Icon(Icons.person, size: 44, color: theme.colorScheme.outline),
                ),
                // Allowed in this concept — it is a normal Grünes-Netz profile,
                // and a picture carries over if the person becomes a member.
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('[Prototyp] Hier öffnet sich die Bildauswahl.'))),
                  child: const Text('Profilbild bearbeiten'),
                ),
                Text(access?.displayName ?? 'Gast', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(access?.email ?? '', style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                // Not editable for guests in this concept. Said here so
                // nobody goes looking for the field.
                Text('Name und E-Mail-Adresse kannst Du als Gast nicht ändern.', style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(terms.access, style: theme.textTheme.bodySmall?.apply(color: ThemeColors.secondary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dein Zugang', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _Row(label: 'Gliederung', value: access?.division ?? '—'),
                _Row(label: 'Eingeladen von', value: access?.invitedBy ?? '—'),
                // The expiry comes from the server. Showing it to the guest is
                // the point — without it no warning is possible.
                _Row(
                  label: 'Gültig bis',
                  value: access?.expiryDate == null
                      ? '—'
                      : '${shortDate(access!.expiryDate!)}  ·  noch ${access.daysLeft} Tage',
                ),
                if (applicationPending)
                  _Row(
                    label: 'Mitgliedschaft',
                    value: 'Antrag vom ${shortDate(ownAccess()!.applicationSubmittedAt!)} wird geprüft',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Was andere sehen', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Mitglieder sehen Deinen Namen mit dem Hinweis „${terms.badge}" — '
                  'in der Mitgliedersuche und im Wahlkampfbereich, etwa in Teams und Ranglisten.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Die Mitgliederliste und Profile anderer kannst Du nicht sehen.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '[Prototyp] Das ist der Mitgliederbereich für Gäste: eigenes Profil '
              'ja, Mitgliedersuche nein.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (guestOffboarding.isOn) ...[const SizedBox(height: 16), _Participation(access: access)],
          const SizedBox(height: 24),
          // Keeps the membership pitch where a guest actually looks at their own
          // status, which is a more honest place for it than a locked tab.
          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: BecomeMemberOrPending()),
          if (guestOffboarding.isOn) ...[const SizedBox(height: 32), const _GiveBackAccount()],
        ],
      ),
    );
  }
}

/// Shown from 14 days out — the same threshold the coordinator's list already
/// reddens at, so both sides get nervous at the same time.
///
/// Two ways forward rather than a warning: a guest cannot extend their own
/// access, so a banner that only announces the end is a dead end.
class _ExpiryBanner extends StatelessWidget {
  const _ExpiryBanner({required this.access});

  final GuestEntry access;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = access.daysLeft ?? 0;

    return Container(
      width: double.infinity,
      color: ThemeColors.sun,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            days <= 0 ? 'Dein Zugang endet heute' : 'Dein Zugang endet in $days ${days == 1 ? 'Tag' : 'Tagen'}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            applicationPending
                ? 'Am ${shortDate(access.expiryDate!)} endet Dein Gastzugang — Dein '
                      'Mitgliedsantrag läuft aber noch. Sag ${access.invitedBy} Bescheid, '
                      'damit in der Zwischenzeit nichts abreißt.'
                : 'Am ${shortDate(access.expiryDate!)} kannst Du Dich nicht mehr anmelden. '
                      'Verlängern kann die Wahlkampfkoordination in ${access.division}.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Anfrage an die Koordination in ${access.division} verschickt.')),
                ),
                child: const Text('Verlängerung anfragen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// What the person has built up here.
///
/// The expiry is abstract until it has something to take away. This is also
/// where the unanswered question becomes concrete: one of the challenges runs
/// longer than the access does, and nothing anywhere says what happens then.
class _Participation extends StatelessWidget {
  const _Participation({required this.access});

  final GuestEntry? access;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiry = access?.expiryDate;

    final own = (ownChallenges(prototypePersona.value)['data'] as List).cast<Map<String, dynamic>>();
    final outlast = expiry == null
        ? const <Map<String, dynamic>>[]
        : own.where((c) => DateTime.parse(c['end'] as String).isAfter(expiry)).toList();

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deine Mitarbeit', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _Dot(text: '${access?.teams.length ?? 0} Team${(access?.teams.length ?? 0) == 1 ? '' : 's'}'),
          _Dot(text: '${own.length} Challenge${own.length == 1 ? '' : 's'}'),
          if (outlast.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: ThemeColors.grey100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${outlast.length == 1 ? 'Eine Challenge läuft' : '${outlast.length} Challenges laufen'} '
                    'länger als Dein Zugang.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(outlast.map((c) => c['title']).join(', '), style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Deine Beiträge bleiben — auch wenn Dein Zugang vorher endet. '
                    'Du wirst dann als ehemalige Teilnahme geführt.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Leaving on your own terms — "Account zurückgeben".
///
/// In this concept guests may delete their own account, for data
/// protection reasons, and it has to happen in the app because guests cannot
/// log in to the Grünes Netz where members would do it.
class _GiveBackAccount extends StatelessWidget {
  const _GiveBackAccount();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => _confirm(context),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: const Text('Account zurückgeben'),
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Account zurückgeben?'),
        content: const Text(
          'Dein Zugang wird gelöscht und Du kannst Dich nicht mehr anmelden. '
          'Was Du erfasst hast — Plakate, Flyer-Orte, Türen — bleibt beim '
          'Wahlkampf Deiner Gliederung.\n\n'
          'Eine erneute Mitarbeit ist möglich, dafür braucht es eine neue '
          'Einladung.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(d).colorScheme.error),
            onPressed: () {
              Navigator.of(d).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('[Prototyp] Account wäre jetzt gelöscht.')));
            },
            child: const Text('Zurückgeben'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// For the screen gallery (guest_gallery.dart).
void showGiveBackAccountDialog(BuildContext context) => const _GiveBackAccount()._confirm(context);
