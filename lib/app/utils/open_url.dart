import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openInAppBrowser(String url, BuildContext context) async {
  FlutterWebBrowser.openWebPage(
    url: url,
    customTabsOptions: CustomTabsOptions(
      defaultColorSchemeParams: CustomTabsColorSchemeParams(toolbarColor: Theme.of(context).primaryColor),
      shareState: CustomTabsShareState.off,
    ),
    safariVCOptions: SafariViewControllerOptions(
      preferredBarTintColor: Theme.of(context).primaryColor,
      preferredControlTintColor: ThemeColors.background,
    ),
  );
}

Future<void> openUrl(String url, BuildContext context) async {
  final parsedUrl = Uri.parse(url);
  if (!parsedUrl.hasScheme) {
    logger.w('Unable to open $url');
    return;
  }

  if (['https', 'http'].contains(parsedUrl.scheme)) {
    await _openInAppBrowser(url, context);
    return;
  }

  final canOpenUrl = await canLaunchUrl(parsedUrl);
  if (canOpenUrl) {
    await launchUrl(parsedUrl);
  } else {
    logger.w('Unable to open $url');
  }
}

Future<void> openMail(String mail, BuildContext context) async {
  await openUrl('mailto:$mail', context);
}
