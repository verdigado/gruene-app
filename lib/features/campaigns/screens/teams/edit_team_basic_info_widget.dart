import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/multiline_text_input_field.dart';
import 'package:gruene_app/features/campaigns/widgets/text_input_field.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EditTeamBasicInfoWidget extends StatefulWidget {
  final Team team;

  const EditTeamBasicInfoWidget({super.key, required this.team});

  @override
  State<EditTeamBasicInfoWidget> createState() => _EditTeamBasicInfoWidgetState();
}

class _EditTeamBasicInfoWidgetState extends State<EditTeamBasicInfoWidget> {
  TextEditingController teamNameTextController = TextEditingController();
  TextEditingController teamDescriptionTextController = TextEditingController();
  bool selfJoin = true;

  @override
  void dispose() {
    teamNameTextController.dispose();
    teamDescriptionTextController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    teamNameTextController.text = widget.team.name;
    teamDescriptionTextController.text = widget.team.description ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 283,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CloseSaveWidget(onClose: onClose, onSave: onSave, saveLabelText: t.common.actions.save),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.campaigns.team.edit_team, style: theme.textTheme.titleMedium),
                ),
                TextInputField(labelText: t.campaigns.team.team_name_label, textController: teamNameTextController),
                MultiLineTextInputField(
                  labelText: t.campaigns.team.team_description_label,
                  textController: teamDescriptionTextController,
                  hint: '',
                  maxLength: 400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onClose() {
    Navigator.pop(context, false);
  }

  Future<void> onSave() async {
    if (teamNameTextController.text.isEmpty) return;
    if (teamDescriptionTextController.text.isEmpty) return;

    // TODO 298 use updateTeamInfo functionality on API
    await Future<void>.delayed(Duration(milliseconds: 250));
    // var teamsService = GetIt.I<GrueneApiTeamsService>();
    // await teamsService.updateTeamInfo(teamNameTextController.text, teamDescriptionTextController.text);

    if (mounted) Navigator.pop(context, true);
  }
}
