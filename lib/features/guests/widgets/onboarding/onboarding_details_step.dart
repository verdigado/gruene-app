import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class OnboardingDetailsStep extends StatelessWidget {
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController birthDate;

  const OnboardingDetailsStep({super.key, required this.firstName, required this.lastName, required this.birthDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = t.guests.onboarding.details;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(texts.title, style: theme.textTheme.titleLarge),
          Text(texts.hint, style: theme.textTheme.bodyMedium),
          FormSection(
            title: texts.firstName.label,
            spacing: 8,
            children: [
              TextFormField(
                controller: firstName,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                validator: (value) => (value?.trim().isEmpty ?? true) ? texts.firstName.required : null,
              ),
            ],
          ),
          FormSection(
            title: texts.lastName.label,
            spacing: 8,
            children: [
              TextFormField(
                controller: lastName,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                validator: (value) => (value?.trim().isEmpty ?? true) ? texts.lastName.required : null,
              ),
            ],
          ),
          FormSection(
            title: texts.birthDate.label,
            spacing: 8,
            children: [
              TextFormField(
                controller: birthDate,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.birthday],
                decoration: InputDecoration(hintText: texts.birthDate.hint),
                validator: (value) => parseBirthDate(value) == null ? texts.birthDate.invalid : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
