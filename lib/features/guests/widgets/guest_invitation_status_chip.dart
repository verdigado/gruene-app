import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInvitationStatusChip extends StatelessWidget {
  final GuestInvitationStatus status;

  const GuestInvitationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      GuestInvitationStatus.open => theme.colorScheme.primary,
      GuestInvitationStatus.accepted => ThemeColors.secondary,
      _ => ThemeColors.textDisabled,
    };

    return Chip(
      label: Text(status.label, style: theme.textTheme.labelSmall?.apply(color: color)),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      visualDensity: VisualDensity(vertical: -4),
      backgroundColor: theme.colorScheme.surface,
      shape: StadiumBorder(),
      side: BorderSide(color: color),
    );
  }
}
