import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/icon.dart';
import 'package:gruene_app/features/campaigns/helper/profile_search_helper.dart';
import 'package:gruene_app/features/campaigns/models/team/new_team_details.dart';
import 'package:gruene_app/features/campaigns/screens/teams/search_screen.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class NewTeamSelectTeamMemberWidget extends StatefulWidget {
  final NewTeamDetails newTeamDetails;
  const NewTeamSelectTeamMemberWidget({super.key, required this.newTeamDetails});

  @override
  State<NewTeamSelectTeamMemberWidget> createState() => _NewTeamSelectTeamMemberWidgetState();
}

class _NewTeamSelectTeamMemberWidgetState extends State<NewTeamSelectTeamMemberWidget> {
  late List<PublicProfile> teamMembers;

  @override
  void initState() {
    teamMembers = widget.newTeamDetails.teamMembers ?? <PublicProfile>[];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 333,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CloseSaveWidget(onClose: onClose, onSave: onSave),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.campaigns.team.select_team_member_label, style: theme.textTheme.titleMedium),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.campaigns.team.select_team_member_hint,
                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.text),
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder(
                  future: _getCurrentTeamLeadProfile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var teamLeadFullname = snapshot.data?.fullName() ?? t.common.notAvailable;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: ThemeColors.textLight)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(teamLeadFullname, style: theme.textTheme.titleMedium)),
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    t.campaigns.team.team_lead_label,
                                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.text),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: CustomIcon(path: 'assets/icons/chess_queen.svg', color: ThemeColors.textDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Row(children: [Text(t.common.actions.loading)]);
                    }
                  },
                ),
                SizedBox(
                  height: 150,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [...(List<int>.generate(9, (i) => i + 1).map((i) => _getMemberWidget(i - 1)))],
                    ),
                  ),
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
    Navigator.pop(context, widget.newTeamDetails.copyWith(teamMembers: teamMembers));
  }

  Future<PublicProfile> _getCurrentTeamLeadProfile() async {
    if (widget.newTeamDetails.selfJoin) {
      return widget.newTeamDetails.creatingUser;
    } else {
      return widget.newTeamDetails.assignedTeamLead!;
    }
  }

  Widget _getMemberWidget(int index) {
    final theme = Theme.of(context);
    var member = teamMembers.length > index ? teamMembers[index] : null;
    var memberFullName = member?.fullName() ?? t.common.notAvailable;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeColors.textLight)),
      ),
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(memberFullName, style: theme.textTheme.titleMedium)),
          GestureDetector(
            onTap: () => _onChangeTeamMember(member),
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
    );
  }

  Future<void> _onChangeTeamMember(PublicProfile? member) async {
    var allCurrentMembersAndLeads = [...teamMembers.map((x) => x.userId), (await _getCurrentTeamLeadProfile()).userId];
    var localContext = context;
    if (!localContext.mounted) return;

    final newTeamMember = await ProfileSearchHelper.searchProfile(
      localContext,
      (userId) => _getActionStateAndText(allCurrentMembersAndLeads, userId),
    );
    if (newTeamMember != null) {
      var allMembersAndLeads = [...teamMembers.map((x) => x.userId), (await _getCurrentTeamLeadProfile()).userId];
      if (!allMembersAndLeads.contains(newTeamMember.userId)) {
        setState(() {
          if (member != null) teamMembers.remove(member);
          teamMembers.add(newTeamMember);
        });
      }
    }
  }

  SearchActionState _getActionStateAndText(List<String> currentTeamMembers, String userId) {
    var userMemberships = currentTeamMembers.where((m) => m == userId);
    if (userMemberships.length == 1) {
      var userMembership = userMemberships.single;
      if (userMembership == widget.newTeamDetails.creatingUser.userId) {
        return SearchActionState.disabled(actionText: t.campaigns.team.team_member);
      } else {
        return SearchActionState.disabled(actionText: t.campaigns.team.invitation_pending);
      }
    }
    return SearchActionState.enabled(actionText: t.campaigns.team.select_as_team_member);
  }
}
