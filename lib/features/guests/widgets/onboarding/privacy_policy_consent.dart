import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class PrivacyConsentField extends StatelessWidget {
  final ValueNotifier<bool> consent;

  const PrivacyConsentField({super.key, required this.consent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField(
      initialValue: consent.value,
      validator: (value) => value == true ? null : t.common.legal.privacyPolicy.required,
      builder: (field) => CheckboxListTile(
        value: field.value,
        onChanged: (value) {
          field.didChange(value);
          consent.value = value ?? false;
        },
        isError: field.hasError,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text.rich(
          t.common.legal.privacyPolicy.label(
            openPrivacyPolicy: (text) => TextSpan(
              text: text,
              style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () => openUrl(privacyPolicyUrl, context),
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: field.hasError
            ? Text(field.errorText!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error))
            : null,
      ),
    );
  }
}

