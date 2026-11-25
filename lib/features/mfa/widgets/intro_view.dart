import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/utils/link.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpandingScrollView(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 32,
      children: [
        Text(t.mfa.intro.title, textAlign: TextAlign.center, style: theme.textTheme.displayMedium),
        Text.rich(
          t.mfa.intro.text(
            appName: TextSpan(text: t.common.appName),
            openAccountSettings: (text) => inlineLink(context, text: text, url: mfaSettingsUrl),
            openMfaInformation: (text) => inlineLink(context, text: text, url: mfaInformationUrl),
          ),
        ),
        FilledButton(
          onPressed: () => context.pushNested(Routes.mfaTokenScan.path),
          child: Text(
            t.mfa.intro.startSetup,
            style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
          ),
        ),
      ],
    );
  }
}
