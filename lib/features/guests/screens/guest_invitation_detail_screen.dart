import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/detail_list_item.dart';
import 'package:gruene_app/app/widgets/status_tag.dart';
import 'package:gruene_app/features/guests/utils/guest_invitation_actions.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/features/guests/widgets/action_buttons.dart';
import 'package:gruene_app/features/guests/widgets/expiry_info.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInvitationDetailExtra {
  final GuestInvitation invitation;
  final Division division;
  final void Function(GuestInvitation updated) onChanged;

  const GuestInvitationDetailExtra({required this.invitation, required this.division, required this.onChanged});
}

class GuestInvitationDetailScreen extends StatefulWidget {
  final GuestInvitationDetailExtra extra;

  const GuestInvitationDetailScreen({super.key, required this.extra});

  @override
  State<GuestInvitationDetailScreen> createState() => _GuestInvitationDetailScreenState();
}

class _GuestInvitationDetailScreenState extends State<GuestInvitationDetailScreen> {
  late GuestInvitation _invitation;

  @override
  void initState() {
    super.initState();
    _invitation = widget.extra.invitation;
  }

  void onChanged(GuestInvitation invitation) {
    setState(() => _invitation = invitation);
    widget.extra.onChanged(invitation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invitation = _invitation;
    final division = widget.extra.division;

    return Scaffold(
      appBar: MainAppBar(title: t.guests.invitation.title),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  DetailListItem.header(
                    title: invitation.email,
                    tag: StatusTag(label: invitation.status.label, color: invitation.status.color(theme)),
                    child: Text(division.shortDisplayName, style: theme.textTheme.bodyLarge),
                  ),
                  DetailListItem(
                    title: invitation.status == GuestInvitationStatus.expired
                        ? t.guests.invitation.expiredAt
                        : t.guests.invitation.validUntil,
                    child: GuestInvitationExpiryInfo(invitation: invitation),
                  ),
                  DetailListItem(title: t.guests.history.title, child: Text(invitation.invitedAtFrom)),
                ],
              ),
            ),
          ),
          ActionButtons(actions: invitation.actions(context), onSuccess: onChanged),
        ],
      ),
    );
  }
}
