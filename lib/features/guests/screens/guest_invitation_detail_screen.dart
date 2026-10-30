import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/features/guests/widgets/action_buttons.dart';
import 'package:gruene_app/features/guests/widgets/guest_invitation_status_chip.dart';
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
    final expiryDate = invitation.expiresAt.formattedDateTime;

    return Scaffold(
      appBar: MainAppBar(title: t.guests.invitation.title),
      body: ExpandingScrollView(
        padding: EdgeInsets.only(bottom: bottomScreenPaddingValue),
        spacing: 16,
        children: [
          ListTile(
            title: Text(invitation.email, style: theme.textTheme.titleLarge),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(division.shortDisplayName, style: theme.textTheme.bodyLarge),
            ),
            trailing: GuestInvitationStatusChip(status: invitation.status),
            tileColor: theme.colorScheme.surface,
            contentPadding: screenPadding.copyWith(bottom: 16),
          ),
          ListTile(
            title: Text(
              invitation.status == GuestInvitationStatus.expired
                  ? t.guests.invitation.expiredAt
                  : t.guests.invitation.validUntil,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                invitation.status == GuestInvitationStatus.revoked ? t.guests.invitation.status.revoked : expiryDate,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            tileColor: theme.colorScheme.surface,
          ),
          ListTile(
            title: Text(t.guests.history.title, style: theme.textTheme.titleMedium),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(invitation.invitedAtFrom, style: theme.textTheme.bodyLarge),
            ),
            tileColor: theme.colorScheme.surface,
          ),
          Spacer(),
          ActionButtons(actions: invitation.actions(context), onSuccess: onChanged),
        ],
      ),
    );
  }
}
