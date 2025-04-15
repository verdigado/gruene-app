import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/features/settings/widgets/settings_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  final bool supportEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            t.settings.support.contacts,
            style: theme.textTheme.titleLarge,
          ),
        ),
        SettingsCard(
          title: t.settings.support.generalFeedback,
          subtitle: supportEnabled ? grueneSupportMail : '',
          icon: Image.asset(
            'assets/icons/gruene.png',
            height: 48,
            width: 48,
            color: supportEnabled ? null : Colors.grey,
            colorBlendMode: supportEnabled ? null : BlendMode.saturation,
          ),
          onPress: () => openMail(grueneSupportMail, context),
          isExternal: true,
          isEnabled: supportEnabled,
        ),
        SettingsCard(
          title: t.settings.support.campaignSupport,
          subtitle: supportEnabled ? pollionSupportMail : '',
          icon: Image.asset(
            'assets/icons/pollion.png',
            height: 48,
            width: 48,
            color: supportEnabled ? null : Colors.grey,
            colorBlendMode: supportEnabled ? null : BlendMode.saturation,
          ),
          onPress: () => openMail(pollionSupportMail, context),
          isExternal: true,
          isEnabled: supportEnabled,
        ),
        SettingsCard(
          title: t.settings.support.otherSupport,
          subtitle: supportEnabled ? verdigadoSupportMail : '',
          icon: Image.asset(
            'assets/icons/verdigado.png',
            height: 48,
            width: 48,
            color: supportEnabled ? null : Colors.grey,
            colorBlendMode: supportEnabled ? null : BlendMode.saturation,
          ),
          onPress: () => openMail(verdigadoSupportMail, context),
          isExternal: true,
          isEnabled: supportEnabled,
        ),
        ...supportEnabled
            ? []
            : [
                Container(
                  margin: EdgeInsets.fromLTRB(8, 8, 8, 24),
                  child: Text.rich(
                    t.settings.support.supportDisabledHint(
                      openGrueneAppArticle: (text) => TextSpan(
                        text: text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ThemeColors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () => openUrl(grueneAppArticleUrl, context),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton(
                    onPressed: () => openUrl(grueneAppFeedbackUrl, context),
                    child: Text(
                      t.settings.support.appFeedbackFormLabel,
                      style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.tertiary),
                    ),
                  ),
                ),
              ],
      ],
    );
  }
}
