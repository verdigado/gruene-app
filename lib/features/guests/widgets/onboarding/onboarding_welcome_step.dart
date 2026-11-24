import 'package:flutter/material.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/step_list_item.dart';
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
        Icon(Icons.waving_hand_outlined, size: 64, color: theme.primaryColor),
        SizedBox(height: 16),
        Text(t.guests.onboarding.welcome.title, style: theme.textTheme.titleLarge),
        Text(
          inviter != null && division != null
              ? t.guests.onboarding.welcome.invitedBy(inviter: inviter, division: division)
              : t.guests.onboarding.welcome.invited,
        ),
        Text(t.guests.onboarding.welcome.hint),
        for (final (index, (title, hint)) in [
          (t.guests.onboarding.welcome.steps.details.title, t.guests.onboarding.welcome.steps.details.hint),
          (t.guests.onboarding.welcome.steps.password.title, t.guests.onboarding.welcome.steps.password.hint),
          (t.guests.onboarding.welcome.steps.login.title, t.guests.onboarding.welcome.steps.login.hint),
          (t.guests.onboarding.welcome.steps.mfa.title, t.guests.onboarding.welcome.steps.mfa.hint),
        ].indexed)
          StepListItem(number: index + 1, title: title, hint: hint),
      ],
    );
  }
}
