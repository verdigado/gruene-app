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
          Text(
            t.mfa.intro.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.displayLarge
          ),
          const SizedBox(height: 32),
          Text(
            t.mfa.intro.info.easyLogin,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(t.mfa.intro.info.noShortMessageNeeded, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          Text.rich(
            t.mfa.intro.info.scanQRCode(
              openMfaSettings: (text) => TextSpan(
                text: text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w700,
                ),
                recognizer: TapGestureRecognizer()..onTap = () => openUrl(mfaSettingsUrl, context),
              ),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Text(t.mfa.intro.info.notificationOnLogin, style: theme.textTheme.bodyMedium),
          FilledButton(
            onPressed: () => context.pushNested(Routes.mfaTokenScan.path),
            style: ButtonStyle(minimumSize: WidgetStateProperty.all(Size.fromHeight(56))),
            child: Text(
              t.mfa.intro.startSetup,
              style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text.rich(
              t.mfa.intro.moreInformation(
                openMfaInformation: (text) => TextSpan(
                  text: text,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ThemeColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () => openUrl(mfaInformationUrl, context),
                ),
              ),
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
