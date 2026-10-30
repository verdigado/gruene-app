import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/guests/utils/actions.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/guest_status_chip.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestListItem extends StatelessWidget {
  final Guest guest;
  final Division division;
  final void Function() onTap;
  final void Function(Guest updated) onChanged;

  const GuestListItem({
    super.key,
    required this.guest,
    required this.division,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiresOn = guest.expiresOn;
    final actions = guest.actions(context);

    return ListTile(
      onTap: onTap,
      title: Text(guest.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(division.shortDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(
            spacing: 8,
            children: [
              if (guest.status == GuestStatus.active && expiresOn != null)
                Text(t.guests.validUntilDate(date: expiresOn.formattedDate)),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GuestStatusChip(status: guest.status),
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
