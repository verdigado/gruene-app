import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/route_locations.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/services/api/guest_api_service.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/selection.dart';
import 'package:gruene_app/features/guests/screens/guest_invitation_detail_screen.dart';
import 'package:gruene_app/features/guests/widgets/guest_invitation_list_item.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInvitationsScreenContainer extends StatelessWidget {
  const GuestInvitationsScreenContainer({super.key});

  Future<({List<Division> divisions, List<GuestInvitation> invitations})> _load() async {
    final service = GetIt.I<GuestApiService>();
    final (divisions, invitations) = await (service.getInvitationDivisions(), service.getInvitations()).wait;
    return (divisions: divisions.sortByLevel(), invitations: invitations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.guests.guestAccess),
      body: FutureLoadingScreen(
        load: _load,
        buildChild: (data, extra) => GuestInvitationsScreen(
          divisions: data.divisions,
          invitations: data.invitations,
          refresh: () async => extra.refresh(),
        ),
      ),
    );
  }
}

class GuestInvitationsScreen extends StatefulWidget {
  final List<Division> divisions;
  final List<GuestInvitation> invitations;
  final Future<void> Function() refresh;

  const GuestInvitationsScreen({super.key, required this.divisions, required this.invitations, required this.refresh});

  @override
  State<GuestInvitationsScreen> createState() => _GuestInvitationsScreenState();
}

class _GuestInvitationsScreenState extends State<GuestInvitationsScreen> {
  late List<GuestInvitation> _invitations;
  Division? _selectedDivision;

  @override
  void initState() {
    super.initState();
    _invitations = widget.invitations;
  }

  Division? _divisionOf(GuestInvitation invitation) =>
      widget.divisions.firstWhereOrNull((division) => division.divisionKey == invitation.divisionKey);

  void _replace(GuestInvitation updated) => setState(
    () => _invitations = _invitations.map((invitation) => invitation.id == updated.id ? updated : invitation).toList(),
  );

  Future<void> _invite() async {
    final created = await context.pushNested(RouteLocations.guestInvite, extra: widget.divisions);
    if (created is GuestInvitation) {
      setState(() => _invitations = [created, ..._invitations]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDivision = _selectedDivision;
    final invitations = selectedDivision == null
        ? _invitations
        : _invitations.where((invitation) => invitation.divisionKey == selectedDivision.divisionKey).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.refresh,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: screenPadding,
              children: [
                if (widget.divisions.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Selection(
                      selected: _selectedDivision,
                      setSelected: (division) => setState(() => _selectedDivision = division),
                      items: widget.divisions,
                      compare: (division1, division2) => division1.divisionKey == division2.divisionKey,
                      filter: (division, query) => division.matches(query),
                      itemAsString: (division) => division.shortDisplayName,
                      label: t.guests.division,
                    ),
                  ),
                if (invitations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Text(t.guests.noInvitations, textAlign: TextAlign.center),
                  ),
                ...invitations.map(
                  (invitation) => GuestInvitationListItem(
                    invitation: invitation,
                    division: _divisionOf(invitation),
                    onTap: () => context.pushNested(
                      invitation.id,
                      extra: GuestInvitationDetailExtra(
                        invitation: invitation,
                        division: _divisionOf(invitation),
                        onChanged: _replace,
                      ),
                    ),
                  ),
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
