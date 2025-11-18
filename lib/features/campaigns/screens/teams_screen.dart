import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var rows = <Widget>[];

    var rowCreateTeam = GestureDetector(
      onTap: _beginCreateNewTeam,
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
    rows.add(rowCreateTeam);

    return Column(children: rows);
  }

  void _beginCreateNewTeam() {}
}
