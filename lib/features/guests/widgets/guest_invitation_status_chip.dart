import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/features/guests/widgets/status_chip.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestInvitationStatusChip extends StatelessWidget {
  final GuestInvitationStatus status;

  const GuestInvitationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      GuestInvitationStatus.open => Theme.of(context).colorScheme.primary,
      GuestInvitationStatus.accepted => ThemeColors.secondary,
      _ => ThemeColors.textDisabled,
    };
    return StatusChip(label: status.label, color: color);
  }
}
