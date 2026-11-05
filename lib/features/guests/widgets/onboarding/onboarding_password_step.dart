import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class OnboardingPasswordStep extends StatefulWidget {
  final String email;
  final TextEditingController password;
  final TextEditingController passwordRepeat;
  final bool rejected;

  const OnboardingPasswordStep({
    super.key,
    required this.email,
    required this.password,
    required this.passwordRepeat,
    required this.rejected,
  });

  @override
  State<OnboardingPasswordStep> createState() => _OnboardingPasswordStepState();
}

class _OnboardingPasswordStepState extends State<OnboardingPasswordStep> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rules = PasswordRules(
      password: widget.password.text,
      repeat: widget.passwordRepeat.text,
      email: widget.email,
    );

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(t.guests.onboarding.password.title, style: theme.textTheme.titleLarge),
          Text(t.guests.onboarding.password.hint(email: widget.email), style: theme.textTheme.bodyMedium),
          FormSection(
            title: t.guests.onboarding.password.label,
            spacing: 8,
            children: [
              TextFormField(
                controller: widget.password,
                // Cutting off a pasted password would silently set a different one than the guest thinks.
                maxLength: PasswordRules.maxLength,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                obscureText: !_showPassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  errorText: widget.rejected ? t.guests.onboarding.password.rejected : null,
                  errorMaxLines: 3,
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    tooltip: _showPassword ? t.guests.onboarding.password.hide : t.guests.onboarding.password.show,
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
            ],
          ),
          FormSection(
            title: t.guests.onboarding.password.repeatLabel,
            spacing: 8,
            children: [
              TextFormField(
                controller: widget.passwordRepeat,
                obscureText: !_showPassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
              ),
            ],
          ),
          Column(
            children: [
              _Rule(text: t.guests.onboarding.password.rules.length, fulfilled: rules.longEnough),
              _Rule(text: t.guests.onboarding.password.rules.letters, fulfilled: rules.hasLetters),
              _Rule(text: t.guests.onboarding.password.rules.digit, fulfilled: rules.hasDigit),
              _Rule(text: t.guests.onboarding.password.rules.notEmail, fulfilled: rules.differsFromEmail),
              _Rule(text: t.guests.onboarding.password.rules.match, fulfilled: rules.match),
            ],
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String text;
  final bool fulfilled;

  const _Rule({required this.text, required this.fulfilled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            fulfilled ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: fulfilled ? ThemeColors.secondary : theme.colorScheme.outline,
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.apply(
                color: fulfilled ? theme.colorScheme.onSurface : theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
