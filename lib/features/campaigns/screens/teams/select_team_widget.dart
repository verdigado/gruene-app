import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class SelectTeamWidget extends StatelessWidget {
  final List<FindTeamsItem> teams;
  const SelectTeamWidget({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .5),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CloseSaveWidget(onClose: () => _onClose(context)),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 4),
              child: Text(t.campaigns.team.select_team, style: theme.textTheme.titleMedium),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 4),
              child: Text(t.campaigns.team.select_team_hint_route),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [...teams.map((t) => _getTeamSelectItem(t, context))]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onClose(BuildContext context) {
    Navigator.pop(context);
  }

  Widget _getTeamSelectItem(FindTeamsItem team, BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [Expanded(child: Text(team.name, style: theme.textTheme.titleMedium, softWrap: true))],
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: ThemeColors.background,
                    child: Text(team.assignedOpenRoutes.toInt().toString()),
                  ),
                  GestureDetector(
                    onTap: () => _selectTeam(team, context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(t.common.actions.select),
                        Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTeam(FindTeamsItem team, BuildContext context) {
    Navigator.pop(context, team);
  }
}
