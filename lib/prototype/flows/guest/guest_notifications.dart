import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';

/// The messages around the end of a guest's access, side by side.
///
/// The concept: a push to the guest 14 days before expiry, and an
/// e-mail once the access is gone — through removal or through expiry —
/// because at that point the app is no longer reachable. Plus a service notice
/// to the coordination about accesses that expire soon.
///
/// Shown as a sheet of previews rather than fired as real notifications: the
/// point in a review is to read the copy and see which channel carries what,
/// not to wait for a push to arrive.
class GuestNotificationsScreen extends StatelessWidget {
  const GuestNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeGuests =
        guestEntries.value.where((e) => e.status == GuestStatus.accepted && e.expiryDate != null).toList()
          ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
    final guest = activeGuests.isEmpty ? null : activeGuests.first;
    final expiringGuests = activeGuests.where((e) => (e.daysLeft ?? 999) <= 14).toList();

    final name = guest?.name?.split(' ').first ?? 'Jonas';
    final division = guest?.division ?? 'KV Berlin-Mitte';
    final date = guest?.expiryDate == null ? '02.10.2026' : shortDate(guest!.expiryDate!);

    return Scaffold(
      appBar: MainAppBar(title: 'Benachrichtigungen'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const _Section(title: 'An den Gast — Push, 14 Tage vorher'),
          _Push(
            title: 'Dein Gastzugang läuft bald ab',
            text:
                'Am $date endet Dein Zugang für $division. Wenn Du weiter '
                'mitmachen möchtest, sprich Deine Wahlkampfkoordination an.',
          ),
          const SizedBox(height: 24),

          const _Section(title: 'An die Koordination — Service-Hinweis'),
          _Push(
            title: expiringGuests.length == 1
                ? '1 Gastzugang läuft bald ab'
                : '${expiringGuests.length} Gastzugänge laufen bald ab',
            text: expiringGuests.isEmpty
                ? 'In den nächsten 14 Tagen läuft kein Zugang ab.'
                : '${expiringGuests.map((e) => e.displayName).join(', ')} — jetzt verlängern oder auslaufen lassen.',
          ),
          const SizedBox(height: 24),

          const _Section(title: 'An den Gast — E-Mail, wenn der Zugang abgelaufen ist'),
          _Mail(
            subject: 'Dein Gastzugang ist abgelaufen',
            text:
                'Hallo $name,\n\n'
                'Dein Gastzugang für $division ist am $date abgelaufen. Du kannst '
                'Dich nicht mehr in der Grünen App anmelden.\n\n'
                'Alles, was Du im Wahlkampf erfasst hast, bleibt erhalten. Danke für '
                'Deine Unterstützung!\n\n'
                'Wenn Du weiter mitmachen möchtest, kann Dich Deine Koordination '
                'jederzeit wieder einladen. Und wenn Du Mitglied werden willst: '
                'gruene.de/mitglied-werden',
          ),
          const SizedBox(height: 16),

          const _Section(title: 'An den Gast — E-Mail, wenn der Zugang gesperrt wurde'),
          _Mail(
            subject: 'Dein Gastzugang wurde beendet',
            text:
                'Hallo $name,\n\n'
                'Dein Gastzugang für $division wurde von der Wahlkampfkoordination '
                'beendet. Du kannst Dich nicht mehr in der Grünen App anmelden.\n\n'
                'Bei Fragen wende Dich bitte an $division.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            color: ThemeColors.grey100,
            child: Text(
              '[Prototyp] Texte sind Entwürfe. Absender, Zeitpunkt des Versands '
              '(am Ablaufdatum oder nach der Grace Period) und ob die Koordination '
              'auch bei einem Entzug durch Dritte informiert wird, sind offen.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// Shaped like an Android notification, so the length of the copy can be
/// judged where it will actually be read.
class _Push extends StatelessWidget {
  const _Push({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: ThemeColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.local_florist, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grüne App · jetzt', style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mail extends StatelessWidget {
  const _Mail({required this.subject, required this.text});
  final String subject;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: ThemeColors.textLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: ThemeColors.grey100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Von: Die Grünen <noreply@example.org>', style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text('Betreff: $subject', style: theme.textTheme.titleSmall),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
