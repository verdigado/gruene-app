import 'package:flutter/material.dart';
import 'package:gruene_app/app/auth/repository/user_info.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/screens/teams/team_profile.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamHome extends StatefulWidget {
  final UserInfo currentUser;

  const TeamHome({super.key, required this.currentUser});

  @override
  State<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends State<TeamHome> with ConfirmDelete {
  bool _loading = true;

  late Team? _currentTeam;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    // TODO remove mock data when getOwnTeam is working
    // var teamsService = GetIt.I<GrueneApiTeamsService>();
    // var team = await teamsService.getOwnTeam();
    var team = Team(
      id: '1',
      userId: '123',
      divisionKey: '5936',
      createdAt: DateTime.now(),
      name: 'Team Oktopus',
      description: '''Bestes HTWK Team jenseits der Panke
Chat: https://signal.group/#123456''',
      status: TeamStatus.active,
      memberships: [
        TeamMembership(
          id: 'id',
          userId: widget.currentUser.uidnumber,
          createdAt: DateTime.now(),
          start: DateTime.now(),
          end: DateTime.now(),
          type: TeamMembershipType.lead,
          status: TeamMembershipStatus.accepted,
        ),
      ],
    );

    setState(() {
      _loading = false;
      _currentTeam = team;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(padding: EdgeInsets.fromLTRB(24, 24, 24, 6), child: CircularProgressIndicator());
    }
    if (_currentTeam == null) return SizedBox.shrink();

    var theme = Theme.of(context);
    return Column(
      children: [
        TeamProfile(currentTeam: _currentTeam!, currentUser: widget.currentUser),
        GestureDetector(
          onTap: _leaveTeam,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.campaigns.team.leave_team, style: theme.textTheme.bodyLarge),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
                ),
              ],
            ),
          ),
        ),
        _currentTeam!.isTeamLead(widget.currentUser)
            ? GestureDetector(
                onTap: _archiveTeam,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(t.campaigns.team.archive_team, style: theme.textTheme.bodyLarge),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox.shrink(),
        SizedBox(height: 24),
      ],
    );
  }

  void _leaveTeam() {
    void executeLeaveTeam() {
      // TODO #300 use leave functionality on API
      // var teamsService = GetIt.I<GrueneApiTeamsService>();
      // teamsService.leaveTeam(_currentTeam.id);
    }

    confirmDelete(
      context,
      onDeletePressed: executeLeaveTeam,
      title: '${t.campaigns.team.leave_team}?',
      confirmationDialogText: t.campaigns.team.leave_team_confirmation_dialog,
      actionTitle: t.common.actions.confirm,
    );
  }

  void _archiveTeam() {
    void executeArchiveTeam() {
      // TODO #735 use archive functionality on API
      // var teamsService = GetIt.I<GrueneApiTeamsService>();
      // teamsService.deleteTeam(_currentTeam.id);
    }

    confirmDelete(
      context,
      onDeletePressed: executeArchiveTeam,
      title: '${t.campaigns.team.archive_team}?',
      confirmationDialogText: t.campaigns.team.archive_team_confirmation_dialog,
      actionTitle: t.common.actions.confirm,
    );
  }
}
