import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/models/filter_model.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/app/widgets/filter_dialog.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/features/guests/screens/guest_detail_screen.dart';
import 'package:gruene_app/features/guests/screens/guest_invitation_detail_screen.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/guest_invitation_list_item.dart';
import 'package:gruene_app/features/guests/widgets/guest_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestAccessScreenContainer extends StatelessWidget {
  const GuestAccessScreenContainer({super.key});

  Future<({List<Division> divisions, List<GuestInvitation> invitations, List<Guest> guests})> _load() async {
    final service = GetIt.I<GuestApiService>();
    final (divisions, invitations, guests) = await (
      service.getInvitationDivisions(),
      service.getInvitations(),
      service.getGuests(),
    ).wait;
    return (divisions: divisions.sortByLevel(), invitations: invitations, guests: guests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.guests.guestAccess),
      body: FutureLoadingScreen(
        load: _load,
        buildChild: (data, extra) => GuestAccessScreen(
          divisions: data.divisions,
          invitations: data.invitations,
          guests: data.guests,
          refresh: () async => extra.refresh(),
        ),
      ),
    );
  }
}

class GuestAccessScreen extends StatefulWidget {
  final List<Division> divisions;
  final List<GuestInvitation> invitations;
  final List<Guest> guests;
  final Future<void> Function() refresh;

  const GuestAccessScreen({
    super.key,
    required this.divisions,
    required this.invitations,
    required this.guests,
    required this.refresh,
  });

  @override
  State<GuestAccessScreen> createState() => _GuestAccessScreenState();
}

class _GuestAccessScreenState extends State<GuestAccessScreen> {
  late List<GuestInvitation> _invitations;
  late List<Guest> _guests;
  String _query = '';
  List<Division> _selectedDivisions = [];

  @override
  void initState() {
    super.initState();
    _invitations = widget.invitations;
    _guests = widget.guests;
  }

  Division? _divisionOf(String divisionKey) =>
      widget.divisions.firstWhereOrNull((division) => division.divisionKey == divisionKey);

  bool _inSelectedDivisions(String divisionKey) =>
      _selectedDivisions.isEmpty || _selectedDivisions.any((division) => division.divisionKey == divisionKey);

  void _replaceInvitation(GuestInvitation updated) => setState(
    () => _invitations = _invitations.map((invitation) => invitation.id == updated.id ? updated : invitation).toList(),
  );

  void _replaceGuest(Guest updated) =>
      setState(() => _guests = _guests.map((guest) => guest.userId == updated.userId ? updated : guest).toList());

  Future<void> _invite() async {
    final created = await context.pushNested(RouteLocations.guestInvite, extra: widget.divisions);
    if (created is GuestInvitation) {
      setState(() => _invitations = [created, ..._invitations]);
    }
  }

  Widget _invitationItem(GuestInvitation invitation) => GuestInvitationListItem(
    invitation: invitation,
    division: _divisionOf(invitation.divisionKey),
    onTap: () => context.pushNested(
      invitation.id,
      extra: GuestInvitationDetailExtra(
        invitation: invitation,
        division: _divisionOf(invitation.divisionKey),
        onChanged: _replaceInvitation,
      ),
    ),
  );

  Widget _guestItem(Guest guest) => GuestListItem(
    guest: guest,
    division: _divisionOf(guest.divisionKey),
    onTap: () => context.pushNested(
      '${RouteLocations.guestDetail}/${guest.userId}',
      extra: GuestDetailExtra(division: _divisionOf(guest.divisionKey), onChanged: _replaceGuest),
    ),
    onChanged: _replaceGuest,
  );

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final invitations = _invitations
        .where((invitation) => _inSelectedDivisions(invitation.divisionKey) && invitation.email.contains(query))
        .toList();
    final guests = _guests.where((guest) => _inSelectedDivisions(guest.divisionKey) && guest.matches(query)).toList();

    List<GuestInvitation> invitationsWith(GuestInvitationStatus status) =>
        invitations.where((invitation) => invitation.status == status).toList();
    List<Guest> guestsWith(GuestStatus status) => guests.where((guest) => guest.status == status).toList();

    final openInvitations = invitationsWith(GuestInvitationStatus.open);
    final activeGuests = guestsWith(GuestStatus.active);
    final blockedGuests = guestsWith(GuestStatus.blocked);
    final expiredGuests = guestsWith(GuestStatus.expired);
    final expiredInvitations = invitationsWith(GuestInvitationStatus.expired);
    final revokedInvitations = invitationsWith(GuestInvitationStatus.revoked);
    final expiredCount = expiredGuests.length + expiredInvitations.length;

    final searchFilter = FilterModel(update: (query) => setState(() => _query = query), initial: '', current: _query);
    final divisionFilter = SelectionFilterModel(
      update: (List<Division> divisions) => setState(() => _selectedDivisions = divisions),
      initial: <Division>[],
      current: _selectedDivisions,
      values: widget.divisions,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          child: RefreshIndicator(
            onRefresh: widget.refresh,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: screenPadding.copyWith(top: 0),
              children: [
                _Section(
                  title: t.guests.section.openInvitations(count: openInvitations.length),
                  emptyText: t.guests.noOpenInvitations,
                  children: openInvitations.map(_invitationItem),
                ),
                _Section(
                  title: t.guests.section.active(count: activeGuests.length),
                  emptyText: t.guests.noActiveGuests,
                  children: activeGuests.map(_guestItem),
                ),
                if (blockedGuests.isNotEmpty)
                  _Section(
                    title: t.guests.section.blocked(count: blockedGuests.length),
                    children: blockedGuests.map(_guestItem),
                  ),
                if (expiredCount > 0)
                  _Section(
                    title: t.guests.section.expired(count: expiredCount),
                    children: [...expiredGuests.map(_guestItem), ...expiredInvitations.map(_invitationItem)],
                  ),
                if (revokedInvitations.isNotEmpty)
                  _Section(
                    title: t.guests.section.revokedInvitations(count: revokedInvitations.length),
                    children: revokedInvitations.map(_invitationItem),
                  ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: screenPadding,
            child: FilledButton(onPressed: _invite, child: Text(t.guests.invite)),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? emptyText;
  final Iterable<Widget> children;

  const _Section({required this.title, required this.children, this.emptyText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyText = this.emptyText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        ...children,
        if (children.isEmpty && emptyText != null) Text(emptyText, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

// showFullScreenDialog creates a new BuildContext, so the dialog keeps a local copy of the selection to show changes
class _GuestFilterDialog extends StatefulWidget {
  final SelectionFilterModel<List<Division>, List<Division>> divisionFilter;

  const _GuestFilterDialog({required this.divisionFilter});

  @override
  State<_GuestFilterDialog> createState() => _GuestFilterDialogState();
}

class _GuestFilterDialogState extends State<_GuestFilterDialog> {
  late List<Division> _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.divisionFilter.current;
  }

  void _setSelection(List<Division> divisions) {
    widget.divisionFilter.update(divisions);
    setState(() => _selection = divisions);
  }

  @override
  Widget build(BuildContext context) {
    return FilterDialog(
      resetFilters: () => _setSelection(widget.divisionFilter.initial),
      modified: widget.divisionFilter.modified(_selection),
      children: [
        FilterSection(
          title: t.divisions.divisions,
          child: MultiSelection(
            selected: _selection,
            setSelected: _setSelection,
            items: widget.divisionFilter.values,
            compare: (division1, division2) => division1.divisionKey == division2.divisionKey,
            filter: (division, query) => division.matches(query),
            itemAsString: (division) => division.shortDisplayName,
            label: t.divisions.divisions,
          ),
        ),
      ],
    );
  }
}
