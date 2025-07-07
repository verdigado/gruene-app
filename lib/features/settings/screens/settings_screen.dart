import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/features/settings/widgets/version_number.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authBloc = context.read<AuthBloc>();
    final isLoggedIn = authBloc.state is Authenticated;
    return Scaffold(
      appBar: MainAppBar(title: t.settings.settings),
      body: ListView(
        padding: const EdgeInsets.only(top: 32),
        children: [
          SectionTitle(title: t.settings.campaignsSettings),
          TextListItem(title: t.settings.inviteNonMember, onPress: () => {}, isImplemented: false),
          TextListItem(title: t.settings.offlineMaps, onPress: () => {}, isImplemented: false),
          SectionTitle(title: t.settings.generalSettings),
          TextListItem(
            title: t.settings.pushNotifications.pushNotifications,
            onPress: () => context.pushNested(Routes.pushNotifications.path),
          ),
          TextListItem(
            title: t.settings.support.support,
            onPress: () => openUrl(grueneAppFeedbackUrl, context),
            isExternal: true,
          ),
          TextListItem(
            title: t.settings.actionNetwork,
            onPress: () => {},
            isExternal: true,
            isImplemented: false,
          ),
          TextListItem(title: t.settings.newsletter, onPress: () => {}, isExternal: true, isImplemented: false),
          SectionTitle(title: t.settings.legalSettings),
          TextListItem(
            title: t.settings.legalNotice,
            onPress: () => openUrl(legalNoticeUrl, context),
            isExternal: true,
          ),
          TextListItem(
            title: t.settings.dataProtectionStatement,
            onPress: () => openUrl(dataProtectionStatementUrl, context),
            isExternal: true,
          ),
          TextListItem(
            title: t.settings.termsOfUse,
            onPress: () => openUrl(termsOfUseUrl, context),
            isExternal: true,
          ),
          isLoggedIn
              ? Container(
                  padding: const EdgeInsets.only(top: 48),
                  child: TextButton(
                    onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                    child: Text(
                      t.settings.logout,
                      style: theme.textTheme.bodyMedium!
                          .apply(color: ThemeColors.text, decoration: TextDecoration.underline),
                    ),
                  ),
                )
              : Container(),
          VersionNumber(),
        ],
      ),
    );
  }
}
