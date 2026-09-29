import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/members_teaser.dart';
import 'package:gruene_app/prototype/settings.dart';

/// The gap between applying for membership and being a member.
///
/// Assumed here: the account carries over, but the membership is not
/// immediate: a manual duplicate check sits in between,
/// hours to days. So there is a fourth state the concept never had, and it is
/// the state in which the ladder is actually climbed.
///
/// Two design assumptions are baked in here:
///
/// 1. **Self-declared.** The application form can be filled anywhere, so the
///    app cannot know. Asking is more reliable than guessing, and unverified
///    is good enough for what it does: not slamming a door, and giving a
///    coordinator a reason to extend. It never merges anything.
/// 2. **Invisible to everyone else.** A pending application is an intention,
///    and an unconfirmed one. Party membership is a special category of
///    personal data; an application is at least as sensitive, because it can
///    still be withdrawn or refused. Nothing about how other members see this
///    person changes until they actually are one.
///
/// **Alternative variant, not part of the concept:** the simpler route is that
/// the app reacts only once the role switches from guest to member. Kept here,
/// off by default, so both can be compared.
final guestMembership = PrototypeToggle(
  id: 'guest.membership',
  label: 'Variante: Mitgliedsantrag läuft',
  description: 'Nicht Teil des Konzepts. Zustand zwischen Antrag und Mitgliedschaft — nur zum Vergleich.',
  defaultOn: false,
);

/// Whether the current guest has said they applied.
bool get applicationPending => guestMembership.isOn && (ownAccess()?.applicationPending ?? false);

void recordApplication() {
  final access = ownAccess();
  if (access == null) return;
  access.applicationSubmittedAt = DateTime.now();
  access.logEvent('Mitgliedsantrag gestellt (selbst angegeben)');
  updateGuest();
}

void withdrawApplication() {
  final access = ownAccess();
  if (access == null) return;
  access.applicationSubmittedAt = null;
  updateGuest();
}

/// After the form: what happens now, and what does not.
///
/// The three things someone wants to know at this moment are all reassurances,
/// and none of them is obvious: it arrived, it takes a while, and nothing
/// stops working in the meantime.
class GuestApplicationSubmittedScreen extends StatelessWidget {
  const GuestApplicationSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final access = ownAccess();

    return Scaffold(
      appBar: MainAppBar(title: 'Mitgliedsantrag'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: ThemeColors.grey100, shape: BoxShape.circle),
              child: Icon(Icons.hourglass_top_outlined, size: 40, color: theme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text('Danke — Dein Antrag ist unterwegs', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            'Bis alles geprüft ist, dauert es einen Moment. Deine Angaben werden '
            'mit dem Mitgliederbestand abgeglichen, und das macht ein Mensch, '
            'keine Maschine.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // The reassurance that matters most, and the one nobody would guess.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: ThemeColors.grey100, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Dot(
                  icon: Icons.check_circle_outline,
                  text: 'Du arbeitest erstmal ganz normal als Gast weiter — nichts ändert sich für Dich.',
                ),
                _Dot(
                  icon: Icons.lock_outline,
                  text: 'Die Bereiche für Mitglieder öffnen sich, sobald Deine Mitgliedschaft bestätigt ist.',
                ),
                _Dot(
                  icon: Icons.person_outline,
                  text: 'Du behältst Dein Konto. Nichts geht verloren, Du musst Dich nicht neu anmelden.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (access?.expiryDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: ThemeColors.textLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Falls Dein Gastzugang vorher endet', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Dein Zugang läuft am ${shortDate(access!.expiryDate!)} ab. Wenn die '
                    'Prüfung dann noch läuft, sag Deiner Koordination Bescheid — sie kann '
                    'verlängern.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Weiter zur App')),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Replaces the membership pitch once an application is running.
///
/// Not a button: there is nothing useful to tap, and leaving an inviting
/// "Jetzt Mitglied werden" in place would ask someone to apply twice — which
/// is exactly how you manufacture the duplicate the manual check then has to
/// resolve.
class ApplicationPendingNotice extends StatelessWidget {
  const ApplicationPendingNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final since = ownAccess()?.applicationSubmittedAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.textLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_top_outlined, size: 18, color: theme.colorScheme.outline),
              const SizedBox(width: 8),
              Text('Antrag in Bearbeitung', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            since == null
                ? 'Dein Mitgliedsantrag wird geprüft. Dieser Bereich öffnet sich, sobald das durch ist.'
                : 'Dein Mitgliedsantrag vom ${shortDate(since)} wird geprüft. Dieser Bereich '
                      'öffnet sich, sobald das durch ist.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// The membership call to action, or the pending notice in its place.
///
/// One widget so the two can never disagree: every surface that pitched
/// membership stops pitching it at the same moment.
class BecomeMemberOrPending extends StatelessWidget {
  const BecomeMemberOrPending({super.key});

  @override
  Widget build(BuildContext context) {
    if (applicationPending) return const ApplicationPendingNotice();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BecomeMemberNotice(),
        // The form opens in the in-app browser and the app never hears back,
        // so it has to ask. Placed under the button because that is the moment
        // someone returns from filling it in.
        if (guestMembership.isOn && ownAccess() != null)
          TextButton(onPressed: () => _confirm(context), child: const Text('Antrag schon gestellt?')),
      ],
    );
  }

  void _confirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Antrag abgeschickt?'),
        content: const Text(
          'Dann merken wir uns das, damit Dir hier nicht weiter der Beitritt '
          'vorgeschlagen wird und Deine Koordination weiß, warum Dein Zugang '
          'noch gebraucht wird.\n\n'
          'Geprüft wird das nicht — die Angabe ändert nichts an Deinem Antrag.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Noch nicht')),
          FilledButton(
            onPressed: () {
              Navigator.of(d).pop();
              recordApplication();
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const GuestApplicationSubmittedScreen()));
            },
            child: const Text('Ja, abgeschickt'),
          ),
        ],
      ),
    );
  }
}
