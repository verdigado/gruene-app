import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      color: Colors.red,
      child: Center(
        child: Text(t.campaigns.team.label, style: TextStyle(fontSize: 20, color: ThemeColors.primary)),
      ),
    );
  }
}
