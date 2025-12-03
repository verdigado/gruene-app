import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_profile_service.dart';
import 'package:gruene_app/app/services/gruene_api_user_service.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/multiline_text_input_field.dart';
import 'package:gruene_app/features/campaigns/widgets/text_input_field.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewTeamBasicInfoWidget extends StatefulWidget {
  const NewTeamBasicInfoWidget({super.key});

  @override
  State<NewTeamBasicInfoWidget> createState() => _NewTeamBasicInfoWidgetState();
}

class _NewTeamBasicInfoWidgetState extends State<NewTeamBasicInfoWidget> {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 331,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CloseSaveWidget(onClose: onClose, onSave: onSave, saveLabelText: t.campaigns.team.next_step),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.campaigns.team.create_new_team, style: theme.textTheme.titleMedium),
                ),
                TextInputField(labelText: t.campaigns.team.team_name_label, textController: teamNameTextController),
                MultiLineTextInputField(
                  labelText: t.campaigns.team.team_description_label,
                  textController: teamDescriptionTextController,
                  hint: '',
                  maxLength: 400,
                ),
                Row(
                  children: [
                    Expanded(child: Text(t.campaigns.team.team_self_join, style: theme.textTheme.labelMedium)),
                    Switch(
                      value: selfJoin,
                      onChanged: (value) => setState(() {
                        selfJoin = value;
                      }),
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

  void onClose() {
    Navigator.pop(context);
  }

  Future<void> onSave() async {
    if (teamNameTextController.text.isEmpty) return;
    if (teamDescriptionTextController.text.isEmpty) return;

    var creatingUser = await _getCreatingUser();
    var newTeamDetails = NewTeamDetails(
      name: teamNameTextController.text,
      description: teamDescriptionTextController.text,
      selfJoin: selfJoin,
      creatingUser: creatingUser,
    );

    if (!context.mounted) return;
    // analyzer seems to ignore the line
    if (mounted) Navigator.pop(context, newTeamDetails);
  }

  Future<PublicProfile> _getCreatingUser() async {
    var profileService = GetIt.I<GrueneApiProfileService>();
    try {
      var currentProfile = await profileService.getSelf();
      return PublicProfile(
        id: currentProfile.id,
        userId: currentProfile.userId,
        personalId: currentProfile.personalId,
        username: currentProfile.username,
        firstName: currentProfile.firstName,
        lastName: currentProfile.lastName,
        phoneNumbers: [],
        messengers: [],
        socialMedia: [],
        tags: [],
        roles: [],
        achievements: [],
      );
    } catch (e) {
      var userService = GetIt.I<GrueneApiUserService>();
      var user = await userService.getSelf();
      return PublicProfile(
        id: user.id,
        userId: '0',
        personalId: '0',
        username: 'username',
        firstName: user.firstName,
        lastName: user.lastName,
        phoneNumbers: [],
        messengers: [],
        socialMedia: [],
        tags: [],
        roles: [],
        achievements: [],
      );
    }
  }
}
