import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/features/campaigns/screens/teams/division_search_screen.dart';
import 'package:gruene_app/features/campaigns/widgets/app_route.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/content_page.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewTeamSelectDivisionWidget extends StatefulWidget {
  final NewTeamDetails newTeamDetails;
  const NewTeamSelectDivisionWidget({super.key, required this.newTeamDetails});

  @override
  State<NewTeamSelectDivisionWidget> createState() => _NewTeamSelectDivisionWidgetState();
}

class _NewTeamSelectDivisionWidgetState extends State<NewTeamSelectDivisionWidget> {
  late Division? currentDivision;

  @override
  void initState() {
    currentDivision = widget.newTeamDetails.assignedDivision;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 170,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CloseSaveWidget(onClose: onClose, onSave: onSave, saveLabelText: t.campaigns.team.next_step),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.campaigns.team.select_division_label, style: theme.textTheme.titleMedium),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.campaigns.team.select_division_hint,
                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.text),
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder(
                  future: _getCurrentDivision(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var divisionName = snapshot.data?.shortDisplayName() ?? t.common.notAvailable;
                      return Row(
                        children: [
                          Expanded(child: Text(divisionName, style: theme.textTheme.titleMedium)),
                          GestureDetector(
                            onTap: onChangeDivision,
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

  void onSave() {
    if (currentDivision == null) return;
    Navigator.pop(context, widget.newTeamDetails.copyWith(assignedDivision: currentDivision));
  }

  void onClose() {
    Navigator.pop(context);
  }

  Future<Division?> _getCurrentDivision() async {
    if (currentDivision != null) return currentDivision!;

    var profileService = GetIt.I<GrueneApiProfileService>();
    try {
      var currentProfile = await profileService.getSelf();
      var memberships = currentProfile.memberships!;
      currentDivision = memberships.firstWhereOrNull((d) => d.division.level == DivisionLevel.kv)?.division;
      return currentDivision;
    } catch (e) {
      return null;
    }
  }

  Future<void> onChangeDivision() async {
    var navState = Navigator.of(context, rootNavigator: true);
    final result = await navState.push(
      AppRoute<Division?>(
        builder: (context) {
          return ContentPage(
            title: t.campaigns.label,
            showBackButton: false,
            contentBackgroundColor: ThemeColors.backgroundSecondary,
            alignment: Alignment.topCenter,
            child: DivisionSearchScreen(),
          );
        },
      ),
    );
    if (result != null) {
      setState(() {
        currentDivision = result;
      });
    }
  }
}
