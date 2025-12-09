import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
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
  final List<PublicProfile> _allProfiles = <PublicProfile>[];

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
                  child: FutureBuilder(
                    future: _acquireAllUserProfiles(),
                    builder: (snapshot, data) {
                      if (data.connectionState != ConnectionState.done || data.error != null) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return SingleChildScrollView(
                        child: Column(children: [..._getMembersWidget(), _getAddTeamMemberAction()]),
                      );
                    },
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

  Future<bool> _acquireAllUserProfiles() async {
    Future<void>.delayed(Duration(milliseconds: 250));
    //get all activeMemberships which profile hasn't been resolved yet
    var unresolvedProfiles = _activeMemberships.where((m) => !_allProfiles.any((p) => p.id == m.userId));
    var profileService = GetIt.I<GrueneApiProfileService>();
    for (var unresolvedProfile in unresolvedProfiles) {
      try {
        _allProfiles.add(await profileService.getProfile(unresolvedProfile.userId));
      } on Exception {
        // TODO #299 remove method to get user name via profile method and use username on membership instead
        _allProfiles.add(
          PublicProfile(
            id: 'id',
            userId: unresolvedProfile.userId,
            personalId: 'personalId',
            username: 'username',
            firstName: '${unresolvedProfile.userId} firstName',
            lastName: 'lastName',
            phoneNumbers: [],
            messengers: [],
            socialMedia: [],
            tags: [],
            roles: [],
            achievements: [],
          ),
        );
      }
    }
    return true;
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
    var userName = _allProfiles.firstWhere((p) => p.userId == teamMembership.userId).fullName();

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            userName,
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

  void _appointAsTeamLead(TeamMembership teamMembership) {
    // TODO #301 appoint as team lead
    // var teamsService = GetIt.I<GrueneApiTeamsService>();
    // teamsService.updateMembership(teamMembership.id, TeamMembershipType.lead);
    var newItem = teamMembership.copyWith(type: TeamMembershipType.lead);
    var index = _activeMemberships.indexOf(teamMembership);
    _activeMemberships.removeAt(index);
    _activeMemberships.insert(index, newItem);
    setState(() {});
  }

  void _removeFromTeam(TeamMembership teamMembership) {
    // TODO #302 #303 remove from team
    // var teamsService = GetIt.I<GrueneApiTeamsService>();
    // teamsService.removeMembership(teamMembership.id);
    _activeMemberships.remove(teamMembership);
    setState(() {});
  }

  Future<void> _addNewTeamMember() async {
    var navState = Navigator.of(context, rootNavigator: true);
    final newTeamMember = await navState.push(
      AppRoute<PublicProfile?>(
        builder: (context) {
          return ContentPage(
            title: t.campaigns.label,
            showBackButton: false,
            contentBackgroundColor: ThemeColors.backgroundSecondary,
            alignment: Alignment.topCenter,
            child: ProfileSearchScreen(actionText: t.campaigns.team.select_as_team_member),
          );
        },
      ),
    );
    if (newTeamMember != null) {
      if (!_activeMemberships.map((m) => m.userId).contains(newTeamMember.userId)) {
        setState(() {
          // TODO #181 add team member to existing team
          _activeMemberships.add(
            TeamMembership(
              id: 'id',
              userId: newTeamMember.userId,
              createdAt: DateTime.now(),
              start: DateTime.now(),
              end: DateTime.now(),
              type: TeamMembershipType.member,
              status: TeamMembershipStatus.pending,
              invitingUserId: '100005',
            ),
          );
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
}
