import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/auth_repository.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_base_service.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_basic_info_widget.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_select_division_widget.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_select_team_lead_widget.dart';
import 'package:gruene_app/features/campaigns/screens/teams/new_team_select_team_member_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var rows = <Widget>[];

    var rowCreateTeam = GestureDetector(
      onTap: () => _beginCreateNewTeam(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: ThemeColors.textLight)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(t.campaigns.team.create_team, style: theme.textTheme.bodyLarge),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
            ),
          ],
        ),
      ),
    );
    rows.add(
      FutureBuilder(
        future: AuthRepository().getUserInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();

          var userInfo = snapshot.data!;
          if (userInfo.isCampaignManager()) {
            return rowCreateTeam;
          }
          return SizedBox.shrink();
        },
      ),
    );

    return Column(children: rows);
  }

  void _beginCreateNewTeam(BuildContext context) async {
    final theme = Theme.of(context);

    var newTeamWidget = NewTeamBasicInfoWidget();
    var newDetails = await showModalBottomSheet<NewTeamDetails>(
      context: context,
      builder: (context) => newTeamWidget,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: theme.colorScheme.surface,
    );

    if (context.mounted) {
      if (newDetails != null) {
        _showStepDivisionSelect(newDetails, context);
      }
    }
  }

  void _showStepDivisionSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    final theme = Theme.of(context);

    var newTeamWidget = NewTeamSelectDivisionWidget(newTeamDetails: newTeamDetails);
    var newDetails = await showModalBottomSheet<NewTeamDetails>(
      context: context,
      builder: (context) => newTeamWidget,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: theme.colorScheme.surface,
    );

    if (context.mounted) {
      if (newDetails != null) {
        _showStepTeamLeadSelect(newDetails, context);
      }
    }
  }

  void _showStepTeamLeadSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    final theme = Theme.of(context);
    NewTeamDetails? newDetails = newTeamDetails;
    if (!newDetails.selfJoin) {
      var newTeamWidget = NewTeamSelectTeamLeadWidget(newTeamDetails: newTeamDetails);
      newDetails = await showModalBottomSheet<NewTeamDetails>(
        context: context,
        builder: (context) => newTeamWidget,
        isScrollControlled: false,
        isDismissible: true,
        backgroundColor: theme.colorScheme.surface,
      );
    }

    if (context.mounted) {
      if (newDetails != null) {
        _showStepTeamMemberSelect(newDetails, context);
      }
    }
  }

  Future<void> _showStepTeamMemberSelect(NewTeamDetails newTeamDetails, BuildContext context) async {
    final theme = Theme.of(context);
    while (true) {
      var newTeamWidget = NewTeamSelectTeamMemberWidget(newTeamDetails: newTeamDetails);
      if (!context.mounted) return;
      var newDetails = await showModalBottomSheet<NewTeamDetails>(
        context: context,
        builder: (context) => newTeamWidget,
        isScrollControlled: false,
        isDismissible: true,
        backgroundColor: theme.colorScheme.surface,
      );

      if (newDetails != null) {
        var teamService = GetIt.I<GrueneApiTeamsService>();

        try {
          await teamService.createNewTeam(newDetails);
          break;
        } on ApiException catch (e) {
          if (context.mounted) showSnackBar(context, e.message);
          newTeamDetails = newDetails;
        }
      }
    }
  }
}
