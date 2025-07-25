import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionNumber extends StatelessWidget {
  const VersionNumber({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 8, 8, 8),
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () => openUrl(releaseNotesUrl, context),
              icon: Icon(Icons.arrow_outward),
              iconAlignment: IconAlignment.end,
              label: Text(t.settings.version(version: '${snapshot.data!.version} (${snapshot.data!.buildNumber})')),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(ThemeColors.text),
                textStyle: WidgetStatePropertyAll(
                  theme.textTheme.bodyMedium!.apply(decoration: TextDecoration.underline),
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
