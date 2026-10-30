import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/features/guests/widgets/guest_invitation_status_chip.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInvitationListItem extends StatelessWidget {
  final GuestInvitation invitation;
  final Division division;
  final void Function() onTap;
  final void Function(GuestInvitation invitation) onChanged;

  const GuestInvitationListItem({
    super.key,
    required this.invitation,
    required this.division,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = invitation.actions(context);

    return ListTile(
      onTap: onTap,
      title: Text(invitation.email, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(division.shortDisplayName), Text(invitation.invitedAtFrom)],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GuestInvitationStatusChip(status: invitation.status),
          if (actions.isNotEmpty)
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => showActions(context: context, actions: actions, onSuccess: onChanged),
            ),
        ],
      ),
      contentPadding: actions.isNotEmpty ? EdgeInsets.only(left: horizontalScreenPaddingValue, right: 4) : null,
    );
  }
}
