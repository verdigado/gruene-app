import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/features/campaigns/screens/teams/profile_search_screen.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewTeamSelectTeamLeadWidget extends StatefulWidget {
  final NewTeamDetails newTeamDetails;
  const NewTeamSelectTeamLeadWidget({super.key, required this.newTeamDetails});

  @override
  State<NewTeamSelectTeamLeadWidget> createState() => _NewTeamSelectTeamLeadWidgetState();
}

class _NewTeamSelectTeamLeadWidgetState extends State<NewTeamSelectTeamLeadWidget> {
  late PublicProfile? currentTeamLeadProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 183,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CloseSaveWidget(onClose: onClose, onSave: onSave, saveLabelText: t.campaigns.team.next_step),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.campaigns.team.select_team_lead_label, style: theme.textTheme.titleMedium),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.campaigns.team.select_team_lead_hint,
                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.text),
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder(
                  future: _getCurrentTeamLeadProfile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var teamLeadFullName = snapshot.data?.fullName() ?? t.common.notAvailable;
                      return Row(
                        children: [
                          Expanded(child: Text(teamLeadFullName, style: theme.textTheme.titleMedium)),
                          GestureDetector(
                            onTap: onChangeTeamLead,
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    t.common.actions.change,
                                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.text),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Row(children: [Text(t.common.actions.loading)]);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onClose() {
    Navigator.pop(context);
  }

  void onSave() {
    if (currentTeamLeadProfile == null) {
      showSnackBar(context, t.campaigns.team.errors.no_team_lead);
      return;
    }
    Navigator.pop(context, widget.newTeamDetails.copyWith(assignedTeamLead: currentTeamLeadProfile));
  }

  Future<PublicProfile?> _getCurrentTeamLeadProfile() async {
    return currentTeamLeadProfile;
  }

  Future<void> onChangeTeamLead() async {
    var navState = Navigator.of(context, rootNavigator: true);
    final result = await navState.push(
      AppRoute<PublicProfile?>(
        builder: (context) {
          return ContentPage(
            title: t.campaigns.label,
            showBackButton: false,
            contentBackgroundColor: ThemeColors.backgroundSecondary,
            alignment: Alignment.topCenter,
            child: ProfileSearchScreen(actionText: t.campaigns.team.select_as_team_lead),
          );
        },
      ),
    );
    if (result != null) {
      setState(() {
        currentTeamLeadProfile = result;
      });
    }
  }
}
