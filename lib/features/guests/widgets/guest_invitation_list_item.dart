import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/guests/widgets/guest_invitation_status_chip.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInvitationListItem extends StatelessWidget {
  final GuestInvitation invitation;
  final Division? division;
  final void Function() onTap;

  const GuestInvitationListItem({super.key, required this.invitation, required this.division, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(invitation.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(division?.shortDisplayName ?? invitation.divisionKey, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(t.guests.invitedAtDate(date: invitation.createdAt.formattedDate)),
          ],
        ),
        trailing: GuestInvitationStatusChip(status: invitation.status),
      ),
    );
  }
}
