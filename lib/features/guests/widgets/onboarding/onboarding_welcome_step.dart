import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  final GuestInvitationLookup invitation;

  const OnboardingWelcomeStep({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inviter = invitation.inviterName;
    final division = invitation.divisionName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.waving_hand_outlined, size: 56, color: theme.primaryColor),
        Text(t.guests.onboarding.welcome.title, style: theme.textTheme.titleLarge),
        Text(
          inviter != null && division != null
              ? t.guests.onboarding.welcome.invitedBy(inviter: inviter, division: division)
              : t.guests.onboarding.welcome.invited,
          style: theme.textTheme.bodyMedium,
        ),
        Text(t.guests.onboarding.welcome.hint, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
