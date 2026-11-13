import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/features/guests/utils/guest_onboarding.dart';
import 'package:gruene_app/features/guests/widgets/onboarding/privacy_policy_consent.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class OnboardingDetailsStep extends StatelessWidget {
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController birthDate;
  final ValueNotifier<bool> privacyConsent;

  const OnboardingDetailsStep({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.privacyConsent,
  });

  Future<void> _pickBirthDate(BuildContext context) async {
    final initialDate = parseBirthDate(birthDate.text);
    final date = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      initialDatePickerMode: initialDate == null ? DatePickerMode.year : DatePickerMode.day,
      firstDate: firstBirthDate,
      lastDate: lastBirthDate,
      helpText: t.guests.onboarding.details.birthDate.label,
      calendarDelegate: const _BirthDateCalendarDelegate(),
    );
    if (date != null) birthDate.text = date.formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(t.guests.onboarding.details.title, style: theme.textTheme.titleLarge),
          Text(t.guests.onboarding.details.hint, style: theme.textTheme.bodyMedium),
          _NameField(
            controller: firstName,
            label: t.guests.onboarding.details.firstName.label,
            requiredMessage: t.guests.onboarding.details.firstName.required,
            autofillHint: AutofillHints.givenName,
          ),
          _NameField(
            controller: lastName,
            label: t.guests.onboarding.details.lastName.label,
            requiredMessage: t.guests.onboarding.details.lastName.required,
            autofillHint: AutofillHints.familyName,
          ),
          FormSection(
            title: t.guests.onboarding.details.birthDate.label,
            spacing: 8,
            children: [
              TextFormField(
                controller: birthDate,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.birthday],
                decoration: InputDecoration(
                  hintText: t.common.dateTime.dateFormatHint,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    tooltip: MaterialLocalizations.of(context).datePickerHelpText,
                    onPressed: () => _pickBirthDate(context),
                  ),
                ),
                validator: (value) => parseBirthDate(value) == null ? t.common.dateTime.error.invalidFormat : null,
              ),
            ],
          ),
          PrivacyConsentField(consent: privacyConsent),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String requiredMessage;
  final String autofillHint;

  const _NameField({
    required this.controller,
    required this.label,
    required this.requiredMessage,
    required this.autofillHint,
  });

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: label,
      spacing: 8,
      children: [
        TextFormField(
          controller: controller,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: [autofillHint],
          validator: (value) => (value?.trim().isEmpty ?? true) ? requiredMessage : null,
        ),
      ],
    );
  }
}

class _BirthDateCalendarDelegate extends GregorianCalendarDelegate {
  const _BirthDateCalendarDelegate();

  @override
  String formatMediumDate(DateTime date, MaterialLocalizations localizations) => date.formattedDate;

  @override
  String formatCompactDate(DateTime date, MaterialLocalizations localizations) => date.formattedDate;
}
