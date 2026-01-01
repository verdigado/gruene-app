import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/screens/teams/profile_search_screen.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EditTeamMembersWidget extends StatefulWidget {
  final Team team;
  final UserRbacStructure currentUser;

  const EditTeamMembersWidget({super.key, required this.team, required this.currentUser});

  @override
  State<EditTeamMembersWidget> createState() => _EditTeamMembersWidgetState();
}

class _EditTeamMembersWidgetState extends State<EditTeamMembersWidget> {
  late List<TeamMembership> _activeMemberships;

  @override
  void initState() {
    _activeMemberships = _getActiveMemberships(widget.team.memberships);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 300,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CloseSaveWidget(onClose: onClose),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.campaigns.team.edit_team_member_label, style: theme.textTheme.titleMedium),
                ),
                SizedBox(height: 16),

                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Column(children: [..._getMembersWidget(), _getAddTeamMemberAction()]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onClose() {
    var currentData = _activeMemberships.map((m) => m.toJson().toString()).join(',');
    var oldData = _getActiveMemberships(widget.team.memberships).map((m) => m.toJson().toString()).join(',');
    var dataChanged = currentData != oldData;
    Navigator.pop(context, dataChanged);
  }

  List<Widget> _getMembersWidget() {
    return _activeMemberships.map((m) => _getMemberWidget(m)).toList();
  }

  Widget _getMemberWidget(TeamMembership teamMembership) {
    var theme = Theme.of(context);

    var actions = <Widget>[];
    if (teamMembership.userId != widget.currentUser.userId) {
      if (teamMembership.status == TeamMembershipStatus.accepted) {
        if (teamMembership.type == TeamMembershipType.member) {
          actions.add(_getActionLink(t.campaigns.team.appoint_as_team_lead, () => _appointAsTeamLead(teamMembership)));
        }
        actions.add(_getActionLink(t.common.actions.remove, () => _removeFromTeam(teamMembership)));
      } else if (teamMembership.status == TeamMembershipStatus.pending) {
        actions.add(_getActionLink(t.campaigns.team.cancel_invitation, () => _removeFromTeam(teamMembership)));
      }
    }
    // Insert in between each action some spacing
    for (var i = actions.length - 1; i > 0; i--) {
      actions.insert(i, SizedBox(width: 8));
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            teamMembership.userName.safe(),
            style: theme.textTheme.bodyLarge?.apply(
              color: teamMembership.status != TeamMembershipStatus.pending
                  ? ThemeColors.textDark
                  : ThemeColors.textDisabled,
            ),
          ),
          Row(children: actions),
        ],
      ),
    );
  }

  List<TeamMembership> _getActiveMemberships(List<TeamMembership> memberships) {
    return memberships
        .where((m) => [TeamMembershipStatus.pending, TeamMembershipStatus.accepted].contains(m.status))
        .toList();
  }

  Widget _getActionLink(String text, void Function() action) {
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () => action(),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDark, decoration: TextDecoration.underline),
      ),
    );
  }

  Future<void> _appointAsTeamLead(TeamMembership teamMembership) async {
    var teamsService = GetIt.I<GrueneApiTeamsService>();
    var updatedTeam = await teamsService.updateTeamMembership(
      teamId: widget.team.id,
      userId: teamMembership.userId,
      membershipType: TeamMembershipType.lead,
    );

    setState(() {
      _activeMemberships = _getActiveMemberships(updatedTeam.memberships);
    });
  }

  Future<void> _removeFromTeam(TeamMembership teamMembership) async {
    var teamsService = GetIt.I<GrueneApiTeamsService>();
    var updatedTeam = await teamsService.removeTeamMembership(teamId: widget.team.id, userId: teamMembership.userId);

    setState(() {
      _activeMemberships = _getActiveMemberships(updatedTeam.memberships);
    });
  }

  Future<void> _addNewTeamMember() async {
    var navState = Navigator.of(context, rootNavigator: true);
    final newTeamMember = await navState.push(
      AppRoute<PublicProfile?>(
        builder: (context) {
          return ContentPage(
            title: t.campaigns.label,
            contentBackgroundColor: ThemeColors.backgroundSecondary,
            alignment: Alignment.topCenter,
            child: ProfileSearchScreen(getActionText: _getActionStateAndText),
          );
        },
      ),
    );
    if (newTeamMember != null) {
      if (!_activeMemberships.map((m) => m.userId).contains(newTeamMember.userId)) {
        var teamService = GetIt.I<GrueneApiTeamsService>();
        var newTeam = await teamService.addTeamMembership(teamId: widget.team.id, userId: newTeamMember.userId);
        setState(() {
          _activeMemberships = _getActiveMemberships(newTeam.memberships);
        });
      }
    }
  }

  Widget _getAddTeamMemberAction() {
    var theme = Theme.of(context);
    if (_activeMemberships.length < 10) {
      return GestureDetector(
        onTap: () => _addNewTeamMember(),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(t.campaigns.team.add_team_member, style: theme.textTheme.bodyLarge),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  SearchActionState _getActionStateAndText(String userId) {
    var activeUserMemberships = _activeMemberships.where((m) => m.userId == userId);
    if (activeUserMemberships.length == 1) {
      var activeUserMembership = activeUserMemberships.single;
      if (activeUserMembership.status == TeamMembershipStatus.accepted) {
        return SearchActionState.disabled(actionText: t.campaigns.team.team_member);
      } else if (activeUserMembership.status == TeamMembershipStatus.pending) {
        return SearchActionState.disabled(actionText: t.campaigns.team.invitation_pending);
      }
    }
    return SearchActionState.enabled(actionText: t.campaigns.team.select_as_team_member);
  }
}
