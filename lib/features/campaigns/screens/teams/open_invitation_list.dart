import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/gruene_api_teams_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/campaigns/helper/team_helper.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class OpenInvitationList extends StatefulWidget {
  final void Function() reload;
  final Team? currentTeam;
  final void Function(bool value) hasInvitationsCallback;

  const OpenInvitationList({
    super.key,
    required this.reload,
    required this.currentTeam,
    required this.hasInvitationsCallback,
  });

  @override
  State<OpenInvitationList> createState() => _OpenInvitationListState();
}

class _OpenInvitationListState extends State<OpenInvitationList> {
  bool _loading = true;
  late List<TeamInvitation> _openInvitations = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    super.initState();
  }

  void _loadData() async {
    setState(() => _loading = true);

    var teamsService = GetIt.I<GrueneApiTeamsService>();
    var openInvitations = await teamsService.getOpenInvitations();

    setState(() {
      _loading = false;
      _openInvitations = openInvitations;
      widget.hasInvitationsCallback(_openInvitations.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Container(padding: EdgeInsets.fromLTRB(24, 24, 24, 6), child: CircularProgressIndicator()),
      );
    }
    if (_openInvitations.isEmpty) return SizedBox.shrink();

    // sort by invite date in descending order
    _openInvitations.sort((inviteA, inviteB) => inviteB.invitationDate.compareTo(inviteA.invitationDate));

    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [Text(t.campaigns.team.invitations.open_invitations_label, style: theme.textTheme.titleMedium)],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.campaigns.team.invitations.open_invitations_description(n: _openInvitations.length),
                  softWrap: true,
                  style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textDark),
                ),
              ),
            ],
          ),
          ..._openInvitations.map(_getInvitationRow),
        ],
      ),
    );
  }

  Widget _getInvitationRow(TeamInvitation invitation) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: boxShadowDecoration,
        child: Column(
          children: [
            Row(
              children: [Expanded(child: Text(invitation.teamName, style: theme.textTheme.titleSmall, softWrap: true))],
            ),
            Row(children: [Text(invitation.teamDivision?.shortDisplayName() ?? '', style: theme.textTheme.labelSmall)]),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    invitation.teamDescription.safe().asRichText(context),
                    style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textDark),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.campaigns.team.invitations.invitation_meta(
                      inviting_user: invitation.invitingUser.safe(),
                      invitation_date: invitation.invitationDate.getAsLocalDateString(),
                      invitation_time: invitation.invitationDate.getAsLocalTimeString(),
                    ),
                    style: theme.textTheme.labelSmall,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _rejectInvitation(invitation),
                  child: Text(
                    t.campaigns.team.invitations.reject,
                    style: theme.textTheme.labelMedium?.apply(
                      color: ThemeColors.textDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _acceptInvitation(invitation),
                  child: Text(
                    t.campaigns.team.invitations.accept,
                    style: theme.textTheme.labelMedium?.apply(
                      color: ThemeColors.textDark,
                      decoration: TextDecoration.underline,
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

  Future<void> _acceptInvitation(TeamInvitation invitation) async {
    if (widget.currentTeam != null) {
      var confirmed = await TeamHelper.getConfirmationJoiningNewTeam(
        context: context,
        currentTeamName: widget.currentTeam!.name,
        newTeamName: invitation.teamName,
      );
      if (!confirmed) return;
    }
    var teamService = GetIt.I<GrueneApiTeamsService>();
    await teamService.acceptTeamMembership(invitation.teamId);
    widget.reload();
  }

  Future<void> _rejectInvitation(TeamInvitation invitation) async {
    var teamService = GetIt.I<GrueneApiTeamsService>();
    await teamService.rejectTeamMembership(invitation.teamId);
    widget.reload();
  }
}
