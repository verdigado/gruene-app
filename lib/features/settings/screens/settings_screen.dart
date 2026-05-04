import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/app/widgets/section_title.dart';
import 'package:gruene_app/app/widgets/text_list_item.dart';
import 'package:gruene_app/features/settings/widgets/version_number.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final isLoggedIn = authBloc.state is Authenticated;
    return Scaffold(
      appBar: MainAppBar(title: t.settings.settings),
      body: ExpandingScrollView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
        children: [
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
          TextListItem(title: t.settings.termsOfUse, onPress: () => openUrl(termsOfUseUrl, context), isExternal: true),
          Spacer(),
          isLoggedIn
              ? Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                    label: Text(t.settings.logout),
                    icon: Icon(Icons.logout),
                  ),
                )
              : Container(),
          VersionNumber(),
        ],
      ),
    );
  }
}
