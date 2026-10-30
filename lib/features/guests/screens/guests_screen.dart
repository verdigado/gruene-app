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
import 'package:gruene_app/app/widgets/expansion_list_tile.dart';
import 'package:gruene_app/app/widgets/filter_bar.dart';
import 'package:gruene_app/features/guests/screens/guest_detail_screen.dart';
import 'package:gruene_app/features/guests/screens/guest_invitation_detail_screen.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/guest_invitation_list_item.dart';
import 'package:gruene_app/features/guests/widgets/guest_list_item.dart';
import 'package:gruene_app/features/guests/widgets/guests_filter_dialog.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestsScreenContainer extends StatelessWidget {
  const GuestsScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.guests.title),
      body: FutureLoadingScreen(
        load: () async {
          final service = GetIt.I<GuestApiService>();
          final divisions = service.getInvitationDivisions();
          final invitations = service.getInvitations();
          final guests = service.getGuests();
          return (divisions: await divisions, invitations: await invitations, guests: await guests);
        },
        buildChild: (data, extra) => GuestsScreen(
          divisions: data.divisions,
          invitations: data.invitations,
          guests: data.guests,
          refresh: extra.refresh,
        ),
      ),
    );
  }
}

class GuestsScreen extends StatefulWidget {
  final List<Division> divisions;
  final List<GuestInvitation> invitations;
  final List<Guest> guests;
  final Future<void> Function() refresh;

  const GuestsScreen({
    super.key,
    required this.divisions,
    required this.invitations,
    required this.guests,
    required this.refresh,
  });

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
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

  bool _inSelectedDivisions(String divisionKey) =>
      _selectedDivisions.isEmpty || _selectedDivisions.any((division) => division.divisionKey == divisionKey);

  void _replaceInvitation(GuestInvitation updated) => setState(
    () => _invitations = _invitations.map((invitation) => invitation.id == updated.id ? updated : invitation).toList(),
  );

  void _replaceGuest(Guest updated) =>
      setState(() => _guests = _guests.map((guest) => guest.userId == updated.userId ? updated : guest).toList());

  Future<void> _invite() async {
    final invitation = await context.pushNested(RouteLocations.guestInvite, extra: widget.divisions);
    if (invitation is GuestInvitation) {
      setState(() => _invitations = [invitation, ..._invitations]);
    }
  }

  Widget _invitationItem(GuestInvitation invitation) => GuestInvitationListItem(
    invitation: invitation,
    division: widget.divisions.byKey(invitation.divisionKey),
    onTap: () => context.pushNested(
      '${RouteLocations.guestInvitations}/${invitation.id}',
      extra: GuestInvitationDetailExtra(
        invitation: invitation,
        division: widget.divisions.byKey(invitation.divisionKey),
        onChanged: _replaceInvitation,
      ),
    ),
    onChanged: _replaceInvitation,
  );

  Widget _guestItem(Guest guest) => GuestListItem(
    guest: guest,
    division: widget.divisions.byKey(guest.divisionKey),
    onTap: () => context.pushNested(
      guest.userId,
      extra: GuestDetailExtra(division: widget.divisions.byKey(guest.divisionKey), onChanged: _replaceGuest),
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

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Padding(
              padding: screenPadding.copyWith(bottom: 0),
              child: FilterBar(
                searchFilter: searchFilter,
                modified: divisionFilter.modified(),
                filterDialog: widget.divisions.length > 1 ? GuestsFilterDialog(divisionFilter: divisionFilter) : null,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: widget.refresh,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    spacing: 32,
                    children: [
                      ExpansionListTile(
                        titleText: t.guests.invitation.sections.open.title(count: openInvitations.length),
                        emptyText: t.guests.invitation.sections.open.empty,
                        children: openInvitations.map(_invitationItem),
                        initiallyExpanded: true,
                      ),
                      ExpansionListTile(
                        titleText: t.guests.sections.active.title(count: activeGuests.length),
                        emptyText: t.guests.sections.active.empty,
                        children: activeGuests.map(_guestItem),
                        initiallyExpanded: true,
                      ),
                      if (blockedGuests.isNotEmpty)
                        ExpansionListTile(
                          titleText: t.guests.sections.blocked(count: blockedGuests.length),
                          children: blockedGuests.map(_guestItem),
                        ),
                      if (expiredCount > 0)
                        ExpansionListTile(
                          titleText: t.guests.sections.expired(count: expiredCount),
                          children: [...expiredGuests.map(_guestItem), ...expiredInvitations.map(_invitationItem)],
                        ),
                      if (revokedInvitations.isNotEmpty)
                        ExpansionListTile(
                          titleText: t.guests.invitation.sections.revoked(count: revokedInvitations.length),
                          children: revokedInvitations.map(_invitationItem),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _invite,
            icon: Icon(Icons.person_add_outlined),
            label: Text(t.guests.invitation.invite),
          ),
        ),
      ],
    );
  }
}
