import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/features/campaigns/helper/division_search_helper.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewTeamSelectDivisionWidget extends StatefulWidget {
  final NewTeamDetails newTeamDetails;
  final UserRbacStructure currentUserInfo;
  const NewTeamSelectDivisionWidget({super.key, required this.newTeamDetails, required this.currentUserInfo});

  @override
  State<NewTeamSelectDivisionWidget> createState() => _NewTeamSelectDivisionWidgetState();
}

class _NewTeamSelectDivisionWidgetState extends State<NewTeamSelectDivisionWidget> {
  late Division? currentDivision;
  bool _loading = true;

  @override
  void initState() {
    currentDivision = widget.newTeamDetails.assignedDivision;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    setState(() => _loading = true);

    var division = await _getCurrentDivision();

    setState(() {
      _loading = false;
      currentDivision = division;
    });
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
                _loading
                    ? Row(children: [Text(t.common.actions.loading)])
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentDivision?.shortDisplayName() ?? t.common.notAvailable,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
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
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onSave() {
    if (currentDivision == null) {
      showToastAsSnack(context, t.campaigns.team.errors.no_division);
      return;
    }
    if (!widget.currentUserInfo.isCampaignManagerInDivision(currentDivision!.divisionKey)) {
      showToastAsSnack(context, t.campaigns.team.errors.no_access_on_division);
      return;
    }

    Navigator.pop(context, widget.newTeamDetails.copyWith(assignedDivision: currentDivision));
  }

  void onClose() {
    Navigator.pop(context);
  }

  Future<Division?> _getCurrentDivision() async {
    if (currentDivision != null) return currentDivision!;

    var profileService = GetIt.I<GrueneApiProfileService>();
    try {
      var currentDivision = (await profileService.getSelf()).getOwnKV();
      return currentDivision;
    } catch (e) {
      return null;
    }
  }

  Future<void> onChangeDivision() async {
    final result = await DivisionSearchHelper.searchDivision(context);

    if (result != null) {
      setState(() {
        currentDivision = result;
      });
    }
  }
}
