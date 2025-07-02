import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ExpandingScrollView(
        children: [
          const SizedBox(height: 32),
          Text(t.mfa.intro.title, textAlign: TextAlign.center, style: theme.textTheme.displayMedium),
          const SizedBox(height: 32),
          Text.rich(
            t.mfa.intro.description(
              appName: TextSpan(text: t.common.appName),
              openAccountSettings: (text) => TextSpan(
                text: text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = () => openUrl(mfaSettingsUrl, context),
              ),
              openMfaInformation: (text) => TextSpan(
                text: text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = () => openUrl(mfaInformationUrl, context),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => context.pushNested(Routes.mfaTokenScan.path),
            style: ButtonStyle(minimumSize: WidgetStateProperty.all(Size.fromHeight(56))),
            child: Text(
              t.mfa.intro.startSetup,
              style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
