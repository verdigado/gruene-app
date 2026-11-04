import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/widgets/form_section.dart';
import 'package:gruene_app/features/guests/utils/guest_invitations.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class OnboardingPasswordStep extends StatefulWidget {
  final String email;
  final TextEditingController password;
  final TextEditingController passwordRepeat;

  const OnboardingPasswordStep({super.key, required this.email, required this.password, required this.passwordRepeat});

  @override
  State<OnboardingPasswordStep> createState() => _OnboardingPasswordStepState();
}

class _OnboardingPasswordStepState extends State<OnboardingPasswordStep> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = t.guests.onboarding.password;
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
          Text(texts.title, style: theme.textTheme.titleLarge),
          Text(texts.hint(email: widget.email), style: theme.textTheme.bodyMedium),
          FormSection(
            title: texts.label,
            spacing: 8,
            children: [
              TextFormField(
                controller: widget.password,
                obscureText: !_showPassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    tooltip: _showPassword ? texts.hide : texts.show,
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
            ],
          ),
          FormSection(
            title: texts.repeatLabel,
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
              _Rule(text: texts.rules.length, fulfilled: rules.longEnough),
              _Rule(text: texts.rules.letters, fulfilled: rules.hasLetters),
              _Rule(text: texts.rules.digit, fulfilled: rules.hasDigit),
              _Rule(text: texts.rules.notEmail, fulfilled: rules.differsFromEmail),
              _Rule(text: texts.rules.match, fulfilled: rules.match),
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
