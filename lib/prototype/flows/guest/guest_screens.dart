import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/prototype/flows/guest/guest_data.dart';
import 'package:gruene_app/prototype/flows/guest/guest_detail.dart';
import 'package:gruene_app/prototype/flows/guest/guest_flow.dart';
import 'package:gruene_app/prototype/flows/guest/guest_terms.dart';
import 'package:gruene_app/prototype/prototype.dart';

/// Rough first-pass screens for the guest flows. Deliberately unpolished —
/// these exist to feel the shape of the flows, not to look finished.

PreferredSizeWidget _bar(BuildContext context, String title, {List<Widget>? actions}) {
  final theme = Theme.of(context);
  return AppBar(
    title: Text(title, style: theme.textTheme.displayMedium?.apply(color: theme.colorScheme.surface)),
    backgroundColor: theme.primaryColor,
    foregroundColor: theme.colorScheme.surface,
    centerTitle: true,
    actions: actions,
  );
}

// ---------------------------------------------------------------------------
// Administration — the management home
// ---------------------------------------------------------------------------

class GuestAdministrationScreen extends StatefulWidget {
  const GuestAdministrationScreen({super.key});

  @override
  State<GuestAdministrationScreen> createState() => _GuestAdministrationScreenState();
}

class _GuestAdministrationScreenState extends State<GuestAdministrationScreen> {
  String _query = '';

  /// Empty means all Gliederungen this person administers — the same default
  /// the news filter uses for divisions.
  List<String> _divisions = [];

  bool _matches(GuestEntry e) {
    if (_divisions.isNotEmpty && !_divisions.contains(e.division)) return false;
    final term = _query.trim().toLowerCase();
    if (term.isEmpty) return true;
    return e.displayName.toLowerCase().contains(term) || e.email.toLowerCase().contains(term);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The app's own filter pattern, as in the member search and the news:
    // search field plus filter button, a full-screen dialog with a
    // multi-select for the Gliederungen.
    final searchFilter = FilterModel(update: (q) => setState(() => _query = q), initial: '', current: _query);
    final divisionFilter = SelectionFilterModel(
      update: (List<String> selection) => setState(() => _divisions = selection),
      initial: <String>[],
      current: _divisions,
      values: prototypePersona.value.managedDivisions,
    );

    return Scaffold(
      appBar: _bar(context, terms.accesses),
      // Bottom left, following the app's own convention: events places its
      // create action at Positioned(bottom: 16, left: 16) in a Stack, and
      // floatingActionButtonLocation is used nowhere. Right is where map and
      // viewport controls live, so create moved left.
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'gast einladen',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GuestInviteScreen())),
        icon: const Icon(Icons.person_add_alt),
        label: Text(terms.invite),
      ),
      body: ValueListenableBuilder<List<GuestEntry>>(
        valueListenable: guestEntries,
        builder: (context, all, _) {
          // Bound to the Gliederung: the list shows only the
          // guests this person may act on. Guests of other Gliederungen stay
          // findable in the member search, read-only.
          final entries = all.where((e) => prototypePersona.value.canManage(e.division) && _matches(e)).toList();
          final pending = entries.where((e) => e.status == GuestStatus.pending).toList();
          final active = entries.where((e) => e.status == GuestStatus.accepted).toList();
          final expiredGuests = entries.where((e) => e.status == GuestStatus.expired).toList();

          // The digest, rather than one push per guest: a Gliederung that ran a
          // campaign can have dozens expiring in the same week, and thirty
          // notifications for one screenful of work is how notifications get
          // switched off.
          final expiringSoon = active.where((e) => (e.daysLeft ?? 999) <= 14).toList();

          return Column(
            children: [
              Padding(
                padding: screenPadding.copyWith(bottom: 8),
                child: FilterBar(
                  searchFilter: searchFilter,
                  modified: divisionFilter.modified(),
                  filterDialog: _GuestFilterDialog(divisionFilter: divisionFilter),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    if (guestOffboarding.isOn && expiringSoon.isNotEmpty)
                      Container(
                        width: double.infinity,
                        color: ThemeColors.sun,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expiringSoon.length == 1
                                  ? '1 Zugang läuft in den nächsten 14 Tagen ab'
                                  : '${expiringSoon.length} Zugänge laufen in den nächsten 14 Tagen ab',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              expiringSoon.map((e) => '${e.displayName} (${e.daysLeft} Tage)').join(' · '),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    _Section(
                      title: 'Offene Einladungen (${pending.length})',
                      children: [
                        for (final e in pending) _EntryTile(entry: e),
                        if (pending.isEmpty) const _Empty('Keine offenen Einladungen.'),
                      ],
                    ),
                    _Section(
                      title: 'Aktive ${terms.accesses} (${active.length})',
                      children: [
                        for (final e in active) _EntryTile(entry: e),
                        if (active.isEmpty) const _Empty('Keine aktiven Gastzugänge.'),
                      ],
                    ),
                    if (expiredGuests.isNotEmpty)
                      _Section(
                        title: 'Abgelaufen (${expiredGuests.length})',
                        children: [for (final e in expiredGuests) _EntryTile(entry: e)],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Same shape as ProfilesFilterDialog and NewsFilterDialog: the full-screen
/// dialog gets its own context, so it keeps a local copy of the selection to
/// reflect changes while it is open.
class _GuestFilterDialog extends StatefulWidget {
  const _GuestFilterDialog({required this.divisionFilter});

  final SelectionFilterModel<List<String>, List<String>> divisionFilter;

  @override
  State<_GuestFilterDialog> createState() => _GuestFilterDialogState();
}

class _GuestFilterDialogState extends State<_GuestFilterDialog> {
  late List<String> _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.divisionFilter.current;
  }

  void _set(List<String> selection) {
    widget.divisionFilter.update(selection);
    setState(() => _selection = selection);
  }

  @override
  Widget build(BuildContext context) {
    return FilterDialog(
      resetFilters: () => _set(widget.divisionFilter.initial),
      modified: widget.divisionFilter.modified(_selection),
      children: [
        FilterSection(
          title: t.divisions.divisions,
          child: MultiSelection<String>(
            selected: _selection,
            setSelected: _set,
            items: widget.divisionFilter.values,
            compare: (a, b) => a == b,
            filter: (division, query) => division.matches(query),
            itemAsString: (division) => division,
            label: t.divisions.divisions,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      ...children,
    ],
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});
  final GuestEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nearExpiry = entry.expiryDate != null && entry.expiryDate!.difference(DateTime.now()).inDays <= 14;

    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GuestDetailScreen(entry: entry))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.displayName, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(entry.division, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusChip(status: entry.status),
                        const SizedBox(width: 8),
                        if (entry.expiryDate != null)
                          Text(
                            'bis ${shortDate(entry.expiryDate!)}',
                            style: theme.textTheme.bodySmall?.apply(color: nearExpiry ? theme.colorScheme.error : null),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _actions(context, entry)),
            ],
          ),
        ),
      ),
    );
  }

  void _actions(BuildContext context, GuestEntry e) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (e.status == GuestStatus.pending) ...[
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Einladung erneut senden'),
                onTap: () => _report(sheet, context, 'Einladung an ${e.displayName} erneut verschickt.'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Einladung zurückziehen'),
                onTap: () {
                  removeGuest(e);
                  _report(sheet, context, 'Einladung an ${e.displayName} zurückgezogen.');
                },
              ),
            ],
            if (e.status == GuestStatus.accepted) ...[
              ListTile(
                leading: const Icon(Icons.more_time),
                title: const Text('Um 90 Tage verlängern'),
                // Unlimited in this concept — no failure path needed.
                onTap: () {
                  e.extend(by: prototypePersona.value.name);
                  updateGuest();
                  _report(sheet, context, 'Zugang von ${e.displayName} verlängert bis ${shortDate(e.expiryDate!)}.');
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Theme.of(context).colorScheme.error),
                title: const Text('Zugang sofort sperren'),
                subtitle: const Text('Wirkt sofort, ohne Übergangsfrist.'),
                onTap: () {
                  Navigator.of(sheet).pop();
                  _confirmBlock(context, e);
                },
              ),
            ],
            if (e.status == GuestStatus.expired)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Erneut einladen'),
                subtitle: const Text('Neues Onboarding nötig — der Zugang war bereits beendet.'),
                onTap: () => _report(sheet, context, 'Neue Einladung an ${e.displayName} verschickt.'),
              ),
          ],
        ),
      ),
    );
  }

  void _report(BuildContext sheet, BuildContext context, String text) {
    Navigator.of(sheet).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _confirmBlock(BuildContext context, GuestEntry e) {
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
              removeGuest(e);
              Navigator.of(d).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Zugang von ${e.displayName} gesperrt.')));
            },
            child: Text('Sperren', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
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
    final color = switch (status) {
      GuestStatus.accepted => ThemeColors.secondary,
      GuestStatus.pending => theme.colorScheme.outline,
      GuestStatus.expired => theme.colorScheme.outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Text(status.label, style: theme.textTheme.bodySmall?.apply(color: color)),
    );
  }
}

// ---------------------------------------------------------------------------
// Invite — inviter side
// ---------------------------------------------------------------------------

class GuestInviteScreen extends StatefulWidget {
  const GuestInviteScreen({super.key, this.email, this.division, this.sent = false});

  /// Start state, used by the screen gallery (guest_gallery.dart) only.
  final String? email;
  final String? division;
  final bool sent;

  @override
  State<GuestInviteScreen> createState() => _GuestInviteScreenState();
}

class _GuestInviteScreenState extends State<GuestInviteScreen> {
  late final _email = TextEditingController(text: widget.email);
  late String? _division = widget.division;
  late bool _sent = widget.sent;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_sent) return _confirmation(theme);

    return Scaffold(
      appBar: _bar(context, terms.invite),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Die eingeladene Person bekommt eine E-Mail mit einem Link zur App. '
            'Den Zugang richtet sie selbst ein.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('E-Mail-Adresse', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'name@beispiel.de'),
          ),
          const SizedBox(height: 24),
          Text('Gliederung', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'In dieser Gliederung arbeitet der Gast mit. Angeboten werden nur '
            'Gliederungen, für die Du einladen darfst.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          // Chosen here, not inherited from the inviter — the two can differ.
          // The Gliederungen this person may invite for — the same set that
          // scopes the administration list. In a real app this
          // comes from the API; the app cannot evaluate the role list itself.
          for (final g in prototypePersona.value.managedDivisions)
            RadioListTile<String>(
              value: g,
              // ignore: deprecated_member_use
              groupValue: _division,
              contentPadding: EdgeInsets.zero,
              title: Text(g),
              // ignore: deprecated_member_use
              onChanged: (v) => setState(() => _division = v),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            color: ThemeColors.grey100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                // No invitation quota in this concept. What the inviter does need
                // to know is how long the access lasts.
                Expanded(
                  child: Text(
                    'Der Zugang gilt 90 Tage. Du oder andere Koordinator*innen Deiner '
                    'Gliederung können ihn danach beliebig oft verlängern.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _email.text.contains('@') && _division != null ? _send : null,
            child: const Text('Einladung senden'),
          ),
        ],
      ),
    );
  }

  void _send() {
    addGuest(GuestEntry(email: _email.text.trim(), division: _division!, status: GuestStatus.pending));
    setState(() => _sent = true);
  }

  Widget _confirmation(ThemeData theme) => Scaffold(
    appBar: _bar(context, 'Einladung gesendet'),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Icon(Icons.mark_email_read_outlined, size: 64, color: theme.primaryColor),
          const SizedBox(height: 24),
          Text('Einladung verschickt', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          // The invitation is in the list straight away, as "Offen" — saying it
          // appears only once accepted would send people looking for nothing.
          Text(
            'Wir haben eine E-Mail an ${_email.text.trim()} geschickt. Du findest '
            'die Einladung in der Übersicht unter "Offen", bis die Person ihren '
            'Zugang eingerichtet hat.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Zur Übersicht')),
          const SizedBox(height: 12),
          // Coordinators tend to invite a handful of helpers at once. Keeps the
          // Gliederung, since the next person is usually for the same one.
          OutlinedButton(
            onPressed: () => setState(() {
              _email.clear();
              _sent = false;
            }),
            child: const Text('Weitere Person einladen'),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Accept — invitee side
// ---------------------------------------------------------------------------

class GuestAcceptInvitationScreen extends StatefulWidget {
  const GuestAcceptInvitationScreen({
    super.key,
    this.startStep = 0,
    this.consent = false,
    this.examplePassword = false,
    this.twoFactorSubStep = 0,
    this.twoFactorDone = false,
  });

  /// Start state, used by the screen gallery (guest_gallery.dart) only.
  final int startStep;
  final bool consent;
  final bool examplePassword;
  final int twoFactorSubStep;
  final bool twoFactorDone;

  @override
  State<GuestAcceptInvitationScreen> createState() => _GuestAcceptInvitationScreenState();
}

class _GuestAcceptInvitationScreenState extends State<GuestAcceptInvitationScreen> {
  static const _steps = 3;

  late int _step = widget.startStep;
  late bool _consent = widget.consent;

  late final _password = TextEditingController(text: widget.examplePassword ? _examplePassword : null);
  late final _passwordRepeat = TextEditingController(text: widget.examplePassword ? _examplePassword : null);
  late bool _showPassword = widget.examplePassword;

  bool _twoFactorRunning = false;
  late bool _twoFactorDone = widget.twoFactorDone;

  /// Sub-step inside the realistic two-factor path: 0 handover, 1 Keycloak
  /// page, 2 switch-context hint, 3 paste into the app.
  late int _twoFactorSubStep = widget.twoFactorSubStep;
  final _tokenField = TextEditingController();
  String? _tokenError;

  @override
  void dispose() {
    _password.dispose();
    _passwordRepeat.dispose();
    _tokenField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _bar(context, '${terms.access} einrichten'),
      body: Column(
        children: [
          // A first-timer needs to know how much is left. The welcome and the
          // done screen sit outside the count.
          if (_step >= 1 && _step <= _steps) _Progress(current: _step, total: _steps),
          Expanded(
            child: switch (_step) {
              0 => _welcome(theme),
              1 => _data(theme),
              2 => _passwordStep(theme),
              3 => _twoFactor(theme),
              _ => _done(theme),
            },
          ),
        ],
      ),
    );
  }

  Widget _welcome(ThemeData theme) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 16),
      Icon(Icons.waving_hand_outlined, size: 56, color: theme.primaryColor),
      const SizedBox(height: 24),
      Text('Du wurdest eingeladen', style: theme.textTheme.titleLarge),
      const SizedBox(height: 12),
      Text(
        'Bea Koordination hat Dich eingeladen, im KV Berlin-Mitte beim '
        'Wahlkampf mitzuhelfen.',
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: 16),
      Text(
        'Dafür richten wir Dir einen Zugang ein. Drei kurze Schritte: '
        'Angaben ergänzen, Passwort vergeben, Anmeldung absichern.',
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: 32),
      FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Los geht\u2019s')),
      TextButton(onPressed: () => _neutralError(context), child: const Text('[Prototyp] Fehlerfall zeigen')),
    ],
  );

  Widget _data(ThemeData theme) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Deine Angaben', style: theme.textTheme.titleLarge),
      const SizedBox(height: 4),
      Text('Name und Geburtsdatum brauchen wir, damit Dein Zugang eindeutig ist.', style: theme.textTheme.bodySmall),
      const SizedBox(height: 20),
      const _Field(label: 'Vorname', mandatory: true),
      const _Field(label: 'Nachname', mandatory: true),
      const _Field(label: 'Geburtsdatum', hint: 'TT.MM.JJJJ', mandatory: true),
      Text('* Pflichtfeld', style: theme.textTheme.bodySmall),
      const SizedBox(height: 8),
      CheckboxListTile(
        value: _consent,
        onChanged: (v) => setState(() => _consent = v ?? false),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          'Ich habe die Datenschutzhinweise gelesen und bin einverstanden.',
          style: theme.textTheme.bodySmall,
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(onPressed: _consent ? () => setState(() => _step = 2) : null, child: const Text('Weiter')),
    ],
  );

  // --- Password --------------------------------------------------------------
  // Nobody is issued a password: in this concept the person sets their own on
  // the login provider's page. This screen stands in for that page shown in
  // the in-app browser — the optimistic variant, where it opens inline and
  // hands control back by itself rather than arriving as a second e-mail.

  /// Satisfies all four rules, so the step can be passed in one tap.
  static const _examplePassword = 'Wahlkampf2026!';

  bool get _longEnough => _password.text.length >= 12;
  bool get _hasDigit => _password.text.contains(RegExp(r'[0-9]'));
  bool get _hasLetters => _password.text.contains(RegExp(r'[a-zäöü]')) && _password.text.contains(RegExp(r'[A-ZÄÖÜ]'));
  bool get _passwordsMatch => _password.text.isNotEmpty && _password.text == _passwordRepeat.text;
  bool get _passwordOk => _longEnough && _hasDigit && _hasLetters && _passwordsMatch;

  Widget _passwordStep(ThemeData theme) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Passwort vergeben', style: theme.textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(
        'Mit Deiner E-Mail-Adresse und diesem Passwort meldest Du Dich künftig an.',
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _password,
        obscureText: !_showPassword,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: 'Passwort',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
            tooltip: _showPassword ? 'Passwort verbergen' : 'Passwort anzeigen',
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _passwordRepeat,
        obscureText: !_showPassword,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: 'Passwort wiederholen',
          border: const OutlineInputBorder(),
          // Only once there is something to compare: telling someone their
          // repeat does not match while they are still typing it is nagging.
          errorText: _passwordRepeat.text.isNotEmpty && !_passwordsMatch ? 'Stimmt nicht überein' : null,
        ),
      ),
      const SizedBox(height: 8),
      // Nobody should type twelve characters twice on a phone in a demo,
      // and the rules here are placeholders anyway — so the demo can skip the
      // typing without skipping the screen.
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() {
            _password.text = _examplePassword;
            _passwordRepeat.text = _examplePassword;
            _showPassword = true;
          }),
          icon: const Icon(Icons.bolt_outlined, size: 18),
          label: const Text('[Prototyp] Beispiel einsetzen'),
        ),
      ),
      const SizedBox(height: 12),
      // Checked live rather than as an error after submitting — the rules are
      // Keycloak's and still a placeholder here.
      _Rule(text: 'Mindestens 12 Zeichen', fulfilled: _longEnough),
      _Rule(text: 'Groß- und Kleinbuchstaben', fulfilled: _hasLetters),
      _Rule(text: 'Mindestens eine Ziffer', fulfilled: _hasDigit),
      _Rule(text: 'Beide Eingaben stimmen überein', fulfilled: _passwordsMatch),
      const SizedBox(height: 24),
      FilledButton(onPressed: _passwordOk ? () => setState(() => _step = 3) : null, child: const Text('Weiter')),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(12),
        color: ThemeColors.grey100,
        child: Text(
          '[Prototyp] Steht für die Keycloak-Seite im In-App-Browser. Die '
          'Regeln gibt Keycloak vor und sind hier Platzhalter.',
          style: theme.textTheme.bodySmall,
        ),
      ),
    ],
  );

  // --- Two-factor ------------------------------------------------------------
  // The optimistic variant: the app receives the Keycloak action token from the
  // same session and registers itself. No QR to scan, no long URL to copy —
  // which is the entire difference from what exists today.

  Widget _twoFactor(ThemeData theme) {
    if (!_twoFactorDone && twoFactorVariant.value == TwoFactorVariant.realistic) {
      return _twoFactorRealistic(theme);
    }
    if (_twoFactorDone) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Icon(Icons.verified_user_outlined, size: 56, color: theme.primaryColor),
          const SizedBox(height: 20),
          Text('Anmeldung ist abgesichert', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            'Diese App ist jetzt Dein zweiter Faktor. Beim nächsten Anmelden '
            'bekommst Du hier eine Nachfrage und tippst auf Bestätigen.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: () => setState(() => _step = 4), child: const Text('Weiter')),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Anmeldung absichern', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(
          'Damit niemand sonst mit Deinem Passwort hereinkommt, bestätigst Du '
          'jede Anmeldung zusätzlich in dieser App.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Das richten wir direkt hier ein. Du musst nichts abtippen und nichts '
          'scannen.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        if (_twoFactorRunning)
          Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Wird eingerichtet …', style: theme.textTheme.bodyMedium),
            ],
          )
        else
          FilledButton(onPressed: _setUpTwoFactor, child: const Text('Jetzt einrichten')),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          color: ThemeColors.grey100,
          child: Text(
            '[Prototyp] Optimistische Variante: die App bekommt den Keycloak-'
            'Action-Token aus derselben Sitzung und registriert sich selbst. '
            'Ob das technisch geht, ist offen.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  // --- Two-factor, realistic variant -----------------------------------------
  // What the app does today. IntroView sends you to account settings in a
  // browser; TokenScanScreen expects a QR from a second screen; TokenInputScreen
  // takes the action token URL by hand. On a phone there is no second screen,
  // so the URL has to be carried across a context switch.

  Widget _twoFactorRealistic(ThemeData theme) => switch (_twoFactorSubStep) {
    0 => _twoFactorHandover(theme),
    1 => _twoFactorKeycloakPage(theme),
    2 => _twoFactorSwitchHint(theme),
    _ => _twoFactorTokenEntry(theme),
  };

  Widget _twoFactorHandover(ThemeData theme) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Anmeldung absichern', style: theme.textTheme.titleLarge),
      const SizedBox(height: 12),
      Text(
        'Damit niemand sonst mit Deinem Passwort hereinkommt, bestätigst Du '
        'jede Anmeldung zusätzlich in dieser App.',
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: 16),
      Text(
        'Dafür öffnen wir kurz die Anmeldeseite. Du bekommst dort einen Link, '
        'den Du anschließend hier einfügst.',
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: 32),
      FilledButton(onPressed: () => setState(() => _twoFactorSubStep = 1), child: const Text('Zur Anmeldeseite')),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(12),
        color: ThemeColors.grey100,
        child: Text(
          '[Prototyp] Realistische Variante: so funktioniert es heute. '
          'Vier Schritte statt einem, mit einem Wechsel zwischen Anmeldeseite '
          'und App.',
          style: theme.textTheme.bodySmall,
        ),
      ),
    ],
  );

  /// Deliberately not styled like the app: the visual break is part of the
  /// friction a guest experiences here.
  Widget _twoFactorKeycloakPage(ThemeData theme) => Container(
    color: const Color(0xFFF2F2F2),
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFFE0E0E0),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 14, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text('saml.gruene.de', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Mobile Authenticator einrichten',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        const Text(
          'Scannen Sie den QR-Code mit der Grünen App.',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 160,
            height: 160,
            color: Colors.white,
            child: const Icon(Icons.qr_code_2, size: 130, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sie können den QR-Code nicht scannen? Kopieren Sie diesen Link und '
          'öffnen Sie ihn in der Grünen App:',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: const Text(
            actionTokenUrl,
            style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.black87),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: actionTokenUrl));
            setState(() => _twoFactorSubStep = 2);
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Link kopieren'),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          color: ThemeColors.grey100,
          child: Text(
            '[Prototyp] Der QR-Code ist auf demselben Gerät nutzlos — man kann '
            'den eigenen Bildschirm nicht scannen. Bleibt der Link.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );

  Widget _twoFactorSwitchHint(ThemeData theme) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 16),
      Icon(Icons.swap_horiz, size: 48, color: theme.colorScheme.outline),
      const SizedBox(height: 20),
      Text('Zurück in die App', style: theme.textTheme.titleLarge),
      const SizedBox(height: 12),
      Text(
        'Der Link ist kopiert. Wechsle jetzt zur Grünen App, öffne dort den '
        'Bereich 2FA und füge den Link ein.',
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: 32),
      FilledButton(onPressed: () => setState(() => _twoFactorSubStep = 3), child: const Text('Zur App wechseln')),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(12),
        color: ThemeColors.grey100,
        child: Text(
          '[Prototyp] Der heikelste Moment: die Person verlässt den Ablauf und '
          'muss selbst zurückfinden. Wer hier abbricht, hat ein Passwort, aber '
          'keinen Zugang.',
          style: theme.textTheme.bodySmall,
        ),
      ),
    ],
  );

  Widget _twoFactorTokenEntry(ThemeData theme) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Link einfügen', style: theme.textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('Füge den Link ein, den Du auf der Anmeldeseite kopiert hast.', style: theme.textTheme.bodyMedium),
      const SizedBox(height: 20),
      TextField(
        controller: _tokenField,
        maxLines: 3,
        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'https://saml.gruene.de/…',
          errorText: _tokenError,
          suffixIcon: IconButton(
            icon: const Icon(Icons.content_paste),
            tooltip: 'Einfügen',
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (!mounted) return;
              setState(() {
                _tokenField.text = data?.text ?? '';
                _tokenError = null;
              });
            },
          ),
        ),
        onChanged: (_) => setState(() => _tokenError = null),
      ),
      const SizedBox(height: 20),
      FilledButton(onPressed: _checkToken, child: const Text('Einrichten')),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(12),
        color: ThemeColors.grey100,
        child: Text(
          '[Prototyp] Entspricht TokenInputScreen. setupMfa prüft, dass der '
          'Link mit der eigenen Keycloak-Instanz beginnt — ein fremder Link '
          'wird abgewiesen.',
          style: theme.textTheme.bodySmall,
        ),
      ),
    ],
  );

  void _checkToken() {
    // Mirrors setupMfa: registration is refused for any other Keycloak instance.
    if (!_tokenField.text.trim().startsWith('https://saml.gruene.de/')) {
      setState(() => _tokenError = 'Dieser Link gehört nicht zur Grünen App.');
      return;
    }
    _setUpTwoFactor();
  }

  Future<void> _setUpTwoFactor() async {
    setState(() => _twoFactorRunning = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _twoFactorRunning = false;
      _twoFactorDone = true;
    });
  }

  Widget _done(ThemeData theme) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        Icon(Icons.check_circle_outline, size: 64, color: theme.primaryColor),
        const SizedBox(height: 24),
        Text('Fertig', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Dein ${terms.access} für den KV Berlin-Mitte ist aktiv. '
          'Du findest den Wahlkampfbereich jetzt in der App.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        // Into Wahlkampf, not wherever the flow was opened from: the app's start
        // tab is News, which for a guest is a locked teaser — the worst possible
        // first screen right after signing up.
        FilledButton(
          onPressed: () {
            final router = GoRouter.of(context);
            Navigator.of(context).popUntil((route) => route.isFirst);
            router.go(Routes.campaigns.path);
          },
          child: const Text('Zur App'),
        ),
      ],
    ),
  );

  /// One message for both "already has access" and "ambiguous match".
  /// Distinguishing them would disclose party membership.
  void _neutralError(BuildContext context) => showNoAccessDialog(context);
}

/// One message for both "already has access" and "ambiguous match".
/// Distinguishing them would disclose party membership.
void showNoAccessDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text('${terms.access} nicht möglich'),
      content: Text(
        'Mit dieser E-Mail-Adresse ist kein Zugang möglich. '
        'Bitte wende Dich an die Person, die Dich eingeladen hat.',
      ),
      actions: [TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Verstanden'))],
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schritt $current von $total', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: current / total, minHeight: 4, backgroundColor: ThemeColors.grey200),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.text, required this.fulfilled});
  final String text;
  final bool fulfilled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            fulfilled ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: fulfilled ? ThemeColors.secondary : theme.colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.apply(
              color: fulfilled ? theme.colorScheme.onSurface : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, this.hint, this.mandatory = false});
  final String label;
  final String? hint;
  final bool mandatory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The app has no required-field convention yet, so this introduces
          // one. Note the collision risk: the asterisk is already in heavy use
          // as the gender star ("Koordinator*innen") throughout the copy.
          Text.rich(
            TextSpan(
              text: label,
              style: theme.textTheme.titleSmall,
              children: [
                if (mandatory)
                  TextSpan(
                    text: ' *',
                    style: theme.textTheme.titleSmall?.apply(color: theme.colorScheme.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(border: const OutlineInputBorder(), hintText: hint),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Einladungs-Mail — stand-in for the real e-mail, so the clickdummy is walkable
// ---------------------------------------------------------------------------

/// 16 characters, grouped in fours. The grouping is a deliberate choice: the
/// fallback only earns its place if someone can actually type it off a screen.
const invitationCode = 'K7M2-9XQ4-B3TR-8WZP';

class GuestInvitationMailScreen extends StatelessWidget {
  const GuestInvitationMailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ThemeColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Posteingang'),
        backgroundColor: ThemeColors.grey200,
        foregroundColor: ThemeColors.text,
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // Deliberately styled like a mail client, not like the app — it has
          // to be obvious that this part happens outside.
          Container(
            color: ThemeColors.background,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Du wurdest zur Grünen App eingeladen', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(radius: 16, child: Text('B')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bea Koordination', style: theme.textTheme.bodyMedium),
                          Text('noreply@example.org  ·  heute, 09:14', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: ThemeColors.background,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hallo,', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(
                  'Bea Koordination lädt Dich ein, im KV Berlin-Mitte beim '
                  'Wahlkampf mitzuhelfen. Dafür bekommst Du einen Zugang '
                  'zur Grünen App.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const GuestAcceptInvitationScreen())),
                    child: const Text('Einladung annehmen'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Der Link führt Dich zuerst in den App Store. Die App brauchst '
                  'Du, um den Zugang einzurichten.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                const HorizontalDividerLine(),
                const SizedBox(height: 20),
                Text('Falls der Link nicht funktioniert', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(
                  'Installiere die Grüne App, tippe auf dem Anmeldebildschirm '
                  'auf „Einladungscode eingeben“ und gib diesen Code ein:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                // Copy affordance follows ProfileCardListItem: Icons.copy in
                // the disabled colour, tapping the row copies. Unlike that one
                // this confirms, since the code is only useful once pasted
                // somewhere else and a silent copy leaves you guessing.
                Material(
                  color: ThemeColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: invitationCode));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code kopiert')));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              invitationCode,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'monospace', letterSpacing: 2),
                            ),
                          ),
                          Icon(Icons.copy, color: theme.disabledColor),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Der Code gilt nur für diese Einladung und kann einmal '
                  'verwendet werden.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '[Prototyp] Dieser Bildschirm steht für die echte E-Mail. '
              'Beide Wege führen weiter: der Button wie der Deep Link, der Code '
              'wie die manuelle Eingabe.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class HorizontalDividerLine extends StatelessWidget {
  const HorizontalDividerLine({super.key});

  @override
  Widget build(BuildContext context) => Container(height: 1, color: ThemeColors.grey200);
}

// ---------------------------------------------------------------------------
// Code eingeben — the fallback when the deep link fails
// ---------------------------------------------------------------------------

class GuestCodeEntryScreen extends StatefulWidget {
  const GuestCodeEntryScreen({super.key, this.code, this.check = false});

  /// Start state, used by the screen gallery (guest_gallery.dart) only: a code
  /// already typed in, and optionally checked right away.
  final String? code;
  final bool check;

  @override
  State<GuestCodeEntryScreen> createState() => _GuestCodeEntryScreenState();
}

class _GuestCodeEntryScreenState extends State<GuestCodeEntryScreen> {
  late final _controller = TextEditingController(text: widget.code);
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.check) WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    // Hyphens and spaces are grouping, not part of the code — someone typing it
    // off a screen should not fail on punctuation.
    String normalized(String code) => code.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (normalized(_controller.text) == normalized(invitationCode)) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const GuestAcceptInvitationScreen()));
      return;
    }
    // Wrong, expired and already-used codes all land here. Whether these may be
    // told apart is an open question: "bereits verwendet" is harmless, but any
    // hint about the person behind the invitation is not.
    setState(
      () => _error =
          'Dieser Code ist nicht gültig. Prüfe die Schreibweise oder wende Dich '
          'an die Person, die Dich eingeladen hat.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _bar(context, 'Einladungscode'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Code eingeben', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Den Code findest Du in der Einladungs-E-Mail. Er gilt nur für '
            'diese Einladung.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontFamily: 'monospace', letterSpacing: 2, fontSize: 20),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'XXXX-XXXX-XXXX-XXXX',
              errorText: _error,
              // Realistically people copy the code out of the mail rather than
              // typing sixteen characters.
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                tooltip: 'Einfügen',
                onPressed: () => setState(() {
                  _controller.text = invitationCode;
                  _error = null;
                }),
              ),
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _check(),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _controller.text.trim().isEmpty ? null : _check, child: const Text('Weiter')),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(12),
            color: ThemeColors.grey100,
            child: Text(
              '[Prototyp] Der Code lautet $invitationCode — über das '
              'Einfügen-Symbol wird er übernommen.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Openers for the screen gallery (guest_gallery.dart), which has to show sheets
// and dialogs the way a tap would open them.
// ---------------------------------------------------------------------------

void showGuestActions(BuildContext context, GuestEntry entry) => _EntryTile(entry: entry)._actions(context, entry);

void showBlockDialog(BuildContext context, GuestEntry entry) => _EntryTile(entry: entry)._confirmBlock(context, entry);

void showGuestFilter(BuildContext context) => showFullScreenDialog<void>(
  context,
  (_) => _GuestFilterDialog(
    divisionFilter: SelectionFilterModel(
      update: (List<String> _) {},
      initial: <String>[],
      current: <String>[],
      values: prototypePersona.value.managedDivisions,
    ),
  ),
);
