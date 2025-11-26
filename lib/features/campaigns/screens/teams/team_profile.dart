import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/auth/repository/user_info.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_divisions_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class TeamProfile extends StatelessWidget {
  final Team currentTeam;
  final UserInfo currentUser;

  const TeamProfile({super.key, required this.currentTeam, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
        child: Column(
          children: [
            currentTeam.isTeamLead(currentUser)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _onEditTeam,
                        child: Text(t.common.actions.edit, style: theme.textTheme.titleSmall?.apply(color: Colors.red)),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            Row(children: [Text(currentTeam.name, style: theme.textTheme.displayLarge)]),
            FutureBuilder(
              future: _getDivisionName(currentTeam.divisionKey),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      Text(snapshot.data!, style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textDisabled)),
                    ],
                  );
                }
                return SizedBox.shrink();
              },
            ),
            Row(
              children: [
                currentTeam.description != null
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(currentTeam.description!, style: theme.textTheme.bodyMedium),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            currentTeam.isTeamLead(currentUser)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _onEditTeamMembers,
                        child: Text(
                          t.campaigns.team.edit_team_members,
                          style: theme.textTheme.titleSmall?.apply(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<String> _getDivisionName(String divisionKey) async {
    var divisionService = GetIt.I<GrueneApiDivisionsService>();
    var division = await divisionService.getDivision(divisionKey);
    return division.shortDisplayName();
  }

  void _onEditTeam() {
    // TODO edit Team and update view after GITHUB ISSUE #298
  }

  void _onEditTeamMembers() {
    // TODO edit Team and update view after GITHUB ISSUE #299
  }
}
