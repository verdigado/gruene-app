import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/urls.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class SupportButton extends StatelessWidget {
  const SupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      right: 24,
      top: 32,
      height: 48,
      child: FilledButton.icon(
        onPressed: () => openUrl(supportUrl, context),
        icon: Icon(Icons.favorite, color: theme.colorScheme.surface),
        label: Text(
          t.login.support,
          style: theme.textTheme.titleMedium?.apply(color: theme.colorScheme.surface),
        ),
      ),
    );
  }
}
