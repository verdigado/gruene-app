import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/guests/utils/guests.dart';
import 'package:gruene_app/features/guests/widgets/status_chip.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class GuestStatusChip extends StatelessWidget {
  final GuestStatus status;

  const GuestStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      GuestStatus.active => ThemeColors.secondary,
      GuestStatus.blocked => Theme.of(context).colorScheme.error,
      _ => ThemeColors.textDisabled,
    };
    return StatusChip(label: status.label, color: color);
  }
}
