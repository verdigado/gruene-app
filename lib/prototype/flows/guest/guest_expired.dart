import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_membership.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/flows/guest/members_teaser.dart';

/// What someone sees when their access has run out.
///
/// The alternative is what happens today without this screen: the login fails
/// and the person gets a generic error, which reads as "the app is broken"
/// rather than "your time here ended". Someone who gave their Saturdays to a
/// campaign deserves better than an error code, and this is also the single
/// best-timed moment in the whole flow to ask whether they want to stay — they
/// have just demonstrated they use the thing they are about to lose.
///
/// Deliberately not a dead end: two ways forward, and neither of them is
/// "contact support".
class GuestExpiredScreen extends StatelessWidget {
  const GuestExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final access = ownAccess();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: ThemeColors.grey100, shape: BoxShape.circle),
                child: Icon(Icons.hourglass_empty, size: 44, color: theme.colorScheme.outline),
              ),
            ),
            const SizedBox(height: 24),
            Text('${terms.access} abgelaufen', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              access?.expiryDate == null
                  ? 'Die Zeit, für die Du eingeladen warst, ist vorbei.'
                  : 'Am ${shortDate(access!.expiryDate!)} endete die Zeit, für die Dich '
                        '${access.invitedBy} eingeladen hatte.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Says plainly what became of the work. Silence here is what makes
            // people assume the worst — and the honest answer is good news.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ThemeColors.grey100, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Was mit Deiner Arbeit passiert ist', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Alles, was Du erfasst hast, bleibt beim Wahlkampf Deiner '
                    'Gliederung — Türen, Plakate, Flyer-Orte. Deine Beiträge zu '
                    'Challenges zählen weiter für Dein Team.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Locking someone out while their membership application is being
            // checked is the worst possible timing, so the screen at least
            // stops pretending this is the end of the story.
            if (applicationPending) ...[const ApplicationPendingNotice(), const SizedBox(height: 16)],

            OutlinedButton(
              onPressed: () => _requestExtension(context, access),
              child: const Text('Verlängerung anfragen'),
            ),
            if (!applicationPending) ...[const SizedBox(height: 12), const BecomeMemberNotice()],
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Du kannst Dich mit diesem Zugang nicht mehr anmelden.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestExtension(BuildContext context, GuestEntry? access) {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Verlängerung anfragen'),
        content: Text(
          'Die Wahlkampfkoordination in ${access?.division ?? 'deiner Gliederung'} bekommt '
          'eine Nachricht, dass Du weiter mitarbeiten möchtest. Verlängern kann '
          'dort jede Person mit Einladerolle.\n\n'
          '[Prototyp] Dass Gäste selbst anfragen können, ist nicht entschieden — '
          'nur, wer verlängern darf.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              Navigator.of(d).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anfrage verschickt.')));
            },
            child: const Text('Anfragen'),
          ),
        ],
      ),
    );
  }
}
