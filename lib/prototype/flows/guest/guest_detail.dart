import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// Detail view for one guest, opened from the Gastzugänge list.
///
/// Full screen rather than a sheet, following the app's own split: sheets are
/// for picking and editing, detail lives in screens like team_profile and
/// route_detail. It also carries history and destructive actions, neither of
/// which belongs in something you dismiss by swiping.
///
/// This is an access record, not a profile. Several coordination roles can
/// extend or block a guest, so this is where accountability for that access
/// lives — and why personal details beyond name and e-mail are deliberately
/// absent.
class GuestDetailScreen extends StatefulWidget {
  const GuestDetailScreen({super.key, required this.entry});

  final GuestEntry entry;

  @override
  State<GuestDetailScreen> createState() => _GuestDetailScreenState();
}

class _GuestDetailScreenState extends State<GuestDetailScreen> {
  GuestEntry get e => widget.entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(terms.access, style: theme.textTheme.displayMedium?.apply(color: theme.colorScheme.surface)),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.surface,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _header(theme),
          _Group(title: 'Zugang', rows: _access()),
          _Group(title: 'Herkunft', rows: _origin()),
          _history(theme),
          _teams(theme),
          _activity(theme),
          const SizedBox(height: 24),
          ..._actions(theme),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme) => Container(
    color: theme.colorScheme.surface,
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(e.displayName, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(e.email, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        _StatusChip(status: e.status),
      ],
    ),
  );

  List<_Row> _access() {
    final rows = <_Row>[_Row('Gliederung', e.division)];

    if (e.status == GuestStatus.pending) {
      // An open invitation runs on its own clock: the activation code expires
      // long before the guest access would, and that is what decides whether
      // resending is the right action.
      rows.add(
        _Row(
          'Einladung gültig bis',
          e.invitationExpiresAt == null ? '—' : shortDate(e.invitationExpiresAt!),
          notice: 'Der Aktivierungscode ist befristet.',
        ),
      );
    } else if (e.expiryDate != null) {
      final days = e.daysLeft ?? 0;
      rows.add(_Row('Zugang gültig bis', '${shortDate(e.expiryDate!)}  ·  noch $days Tage', warning: days <= 14));
    }

    if (e.status == GuestStatus.accepted) {
      // Unlimited in this concept, so the count is history, not headroom.
      rows.add(_Row('Verlängerung', e.extensions == 0 ? 'Noch nie verlängert' : '${e.extensions}× verlängert'));
    }

    return rows;
  }

  List<_Row> _origin() => [
    _Row('Eingeladen von', e.invitedBy),
    _Row('Eingeladen am', shortDate(e.invitedAt)),
    if (e.acceptedAt != null) _Row('Angenommen am', shortDate(e.acceptedAt!)),
  ];

  Widget _history(ThemeData theme) {
    if (e.history.isEmpty) return const SizedBox.shrink();
    return _Group(
      title: 'Verlauf',
      kind: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final event in e.history.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: ThemeColors.secondary, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.what, style: theme.textTheme.bodyMedium),
                        Text(
                          event.by == null
                              ? shortDate(event.timestamp)
                              : '${shortDate(event.timestamp)}  ·  ${event.by}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _teams(ThemeData theme) => _Group(
    title: 'Mitarbeit',
    kind: e.teams.isEmpty
        ? Text('In keinem Team.', style: theme.textTheme.bodySmall)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final team in e.teams)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.group_outlined, size: 18, color: theme.colorScheme.outline),
                      const SizedBox(width: 10),
                      Text(team, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
            ],
          ),
  );

  /// Left as a placeholder on purpose: door counts and last-active are the most
  /// useful signal for extend-or-drop, but they shift this screen from "who has
  /// access" to "what they did". That is an open question, not a detail.
  Widget _activity(ThemeData theme) => _Group(
    title: 'Aktivität',
    kind: Container(
      padding: const EdgeInsets.all(12),
      color: ThemeColors.grey100,
      child: Text(
        '[Prototyp] Hier könnten erfasste Türen und letzte Aktivität stehen. '
        'Bewusst offen: das wäre ein anderer Datentyp als die Zugangsdaten '
        'darüber.',
        style: theme.textTheme.bodySmall,
      ),
    ),
  );

  List<Widget> _actions(ThemeData theme) {
    final buttons = <Widget>[];

    // Reachable from the member search as well as from the list, and from
    // there for guests of any Gliederung. Seeing the record is not the same as
    // being allowed to change it.
    if (!prototypePersona.value.canManage(e.division)) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: ThemeColors.grey100,
            child: Text(
              'Nur zur Ansicht. Verlängern oder sperren kann, wer für '
              '${e.division} berechtigt ist.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ];
    }

    if (e.status == GuestStatus.pending) {
      buttons.addAll([
        FilledButton.icon(
          onPressed: () => _report('Einladung an ${e.displayName} erneut verschickt.'),
          icon: const Icon(Icons.mail_outline),
          label: const Text('Einladung erneut senden'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            removeGuest(e);
            Navigator.of(context).pop();
            messenger.showSnackBar(SnackBar(content: Text('Einladung an ${e.displayName} zurückgezogen.')));
          },
          icon: const Icon(Icons.close),
          label: const Text('Einladung zurückziehen'),
        ),
      ]);
    }

    if (e.status == GuestStatus.accepted) {
      buttons.addAll([
        FilledButton.icon(
          onPressed: _extend,
          icon: const Icon(Icons.more_time),
          label: const Text('Um 90 Tage verlängern'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _confirmBlock,
          style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
          icon: const Icon(Icons.block),
          label: const Text('Zugang sofort sperren'),
        ),
      ]);
    }

    if (e.status == GuestStatus.expired) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _report('Neue Einladung an ${e.displayName} verschickt.'),
          icon: const Icon(Icons.refresh),
          label: const Text('Erneut einladen'),
        ),
      );
    }

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons),
      ),
    ];
  }

  void _extend() {
    setState(() => e.extend(by: prototypePersona.value.name));
    updateGuest();
    _report('Zugang von ${e.displayName} verlängert bis ${shortDate(e.expiryDate!)}.');
  }

  void _report(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _confirmBlock() {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Zugang sperren?'),
        content: Text(
          '${e.displayName} verliert sofort den Zugang zur App und bekommt '
          'darüber eine E-Mail — in die App kommt die Person ja nicht mehr. '
          'Erfasste Wahlkampfdaten bleiben erhalten.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              removeGuest(e);
              Navigator.of(d).pop();
              Navigator.of(context).pop();
              messenger.showSnackBar(SnackBar(content: Text('Zugang von ${e.displayName} gesperrt.')));
            },
            child: Text('Sperren', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _Row {
  _Row(this.label, this.value, {this.notice, this.warning = false});
  final String label;
  final String value;
  final String? notice;
  final bool warning;
}

class _Group extends StatelessWidget {
  const _Group({required this.title, this.rows, this.kind});

  final String title;
  final List<_Row>? rows;
  final Widget? kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ?kind,
            if (rows != null)
              for (final z in rows!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(z.label, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        z.value,
                        style: theme.textTheme.bodyLarge?.apply(color: z.warning ? theme.colorScheme.error : null),
                      ),
                      if (z.notice != null) Text(z.notice!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final GuestStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status == GuestStatus.accepted ? ThemeColors.secondary : theme.colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Text(status.label, style: theme.textTheme.bodySmall?.apply(color: color)),
    );
  }
}
