import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/divisions.dart';
import 'package:gruene_app/features/guests/utils/guest_actions.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/guest_status_chip.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestListItem extends StatelessWidget {
  final Guest guest;
  final Division? division;
  final void Function() onTap;
  final void Function(Guest updated) onChanged;

  const GuestListItem({
    super.key,
    required this.guest,
    required this.division,
    required this.onTap,
    required this.onChanged,
  });

  Future<void> _showActions(BuildContext context) async {
    final action = await showModalBottomSheet<GuestAction>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: GuestAction.availableFor(guest.status).map((action) {
            final hint = action.hint;
            return ListTile(
              leading: Icon(action.icon, color: action == GuestAction.block ? Theme.of(sheet).colorScheme.error : null),
              title: Text(action.label),
              subtitle: hint != null ? Text(hint) : null,
              onTap: () => Navigator.of(sheet).pop(action),
            );
          }).toList(),
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final updated = await action.run(context, guest);
    if (updated != null) onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiresOn = guest.expiresOn;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(guest.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(division?.shortDisplayName ?? guest.divisionKey, maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              spacing: 8,
              children: [
                GuestStatusChip(status: guest.status),
                if (guest.status == GuestStatus.active && expiresOn != null)
                  Text(t.guests.validUntil(date: expiresOn.formattedDate)),
              ],
            ),
          ],
        ),
        trailing: GuestAction.availableFor(guest.status).isEmpty
            ? null
            : IconButton(icon: Icon(Icons.more_vert), onPressed: () => _showActions(context)),
      ),
    );
  }
}
