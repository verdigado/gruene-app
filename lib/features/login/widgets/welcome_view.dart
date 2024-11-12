import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/login/bloc/auth_bloc.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Spacer(),
        SizedBox(
          height: 256,
          child: SvgPicture.asset('assets/graphics/login.svg'),
        ),
        Center(
          child: Text(t.login.welcome, style: theme.textTheme.displayLarge?.apply(color: ThemeColors.text)),
        ),
        Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          height: 64,
          child: FilledButton(
            onPressed: () => context.read<AuthBloc>().add(SignInRequested()),
            child: Text(t.login.loginMembers, style: theme.textTheme.titleMedium),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: OutlinedButton(
            onPressed: () => {},
            child: Text(
              t.login.loginNonMembers,
              style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.tertiary),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => {},
              child: Text(
                t.login.dataProtection,
                style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textAccent),
              ),
            ),
            Icon(Icons.circle, size: 4),
            TextButton(
              onPressed: () => {},
              child: Text(
                t.login.legalNotice,
                style: theme.textTheme.labelSmall?.apply(color: ThemeColors.textAccent),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
