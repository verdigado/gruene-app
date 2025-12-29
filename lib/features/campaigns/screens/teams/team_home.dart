import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/screens/teams/open_invitation_list.dart';
import 'package:gruene_app/features/campaigns/screens/teams/profile_visibility_hint.dart';
// import 'package:gruene_app/features/campaigns/screens/teams/team_assigned_elements.dart';
// import 'package:gruene_app/features/campaigns/screens/teams/team_member_statistics.dart';
import 'package:gruene_app/features/campaigns/screens/teams/team_profile.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamHome extends StatefulWidget {
  final UserRbacStructure currentUser;

  const TeamHome({super.key, required this.currentUser});

  @override
  State<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends State<TeamHome> with ConfirmDelete {
  bool _loading = true;

  late Team? _currentTeam;
  late Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData({Team? preloadedTeam, Profile? preloadedProfile}) async {
    setState(() => _loading = true);

    Profile? profile;
    try {
      var profileService = GetIt.I<GrueneApiProfileService>();
      profile = preloadedProfile ?? await profileService.getSelf();
    } catch (e) {
      profile = null;
    }

    var teamsService = GetIt.I<GrueneApiTeamsService>();
    var team = preloadedTeam ?? await teamsService.getOwnTeam();

    setState(() {
      _loading = false;
      _currentTeam = team;
      _currentProfile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Container(padding: EdgeInsets.fromLTRB(24, 24, 24, 6), child: CircularProgressIndicator()),
      );
    }
    var subItems = <Widget>[];

    subItems.add(
      ProfileVisibilityHint(
        currentProfile: _currentProfile,
        reloadProfile: (profile) => _loadData(preloadedTeam: _currentTeam, preloadedProfile: profile),
      ),
    );

    subItems.add(
      OpenInvitationList(
        reload: () => _loadData(preloadedProfile: _currentProfile),
        currentTeam: _currentTeam,
      ),
    );

    if (_currentTeam != null) {
      subItems.addAll(_getTeamWidgets(context));
    }

    return Column(children: [...subItems]);
  }

  Iterable<Widget> _getTeamWidgets(BuildContext context) sync* {
    var theme = Theme.of(context);
    yield TeamProfile(
      currentTeam: _currentTeam!,
      currentUser: widget.currentUser,
      reloadTeam: (team) => _loadData(preloadedProfile: _currentProfile, preloadedTeam: team),
    );
    // TODO features not ready yet - disable them for now
    // yield TeamAssignedElements(currentTeam: _currentTeam!);
    // yield TeamMemberStatistics(currentTeam: _currentTeam!);
    yield GestureDetector(
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
    );
    yield _currentTeam!.isTeamLead(widget.currentUser)
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
        : SizedBox.shrink();
    yield SizedBox(height: 24);
  }

  void _leaveTeam() {
    Future<void> executeLeaveTeam() async {
      var teamsService = GetIt.I<GrueneApiTeamsService>();
      teamsService.leaveTeam(_currentTeam!.id);
      _loadData(preloadedProfile: _currentProfile);
    }

    confirmDelete(
      context,
      onDeletePressed: executeLeaveTeam,
      title: t.campaigns.team.leave_team,
      confirmationDialogText: t.campaigns.team.leave_team_confirmation_dialog,
      actionTitle: t.common.actions.confirm,
    );
  }

  void _archiveTeam() {
    Future<void> executeArchiveTeam() async {
      var teamsService = GetIt.I<GrueneApiTeamsService>();
      teamsService.archiveTeam(_currentTeam!.id);
      _loadData(preloadedProfile: _currentProfile);
    }

    confirmDelete(
      context,
      onDeletePressed: executeArchiveTeam,
      title: t.campaigns.team.archive_team,
      confirmationDialogText: t.campaigns.team.archive_team_confirmation_dialog,
      actionTitle: t.common.actions.confirm,
    );
  }
}
