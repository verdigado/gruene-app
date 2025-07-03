import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoLoginAttemptCard extends StatelessWidget {
  final DateTime? lastRefresh;

  const NoLoginAttemptCard({super.key, required this.lastRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = LocaleSettings.currentLocale.languageCode;
    final formattedLastRefresh = lastRefresh != null ? timeago.format(lastRefresh!, locale: locale) : t.mfa.ready.never;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(2, 4),
            blurRadius: 16,
            spreadRadius: 7,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.mfa.ready.noLoginAttempt, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(
                t.mfa.ready.lastRefresh(time: formattedLastRefresh),
                style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.textDisabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
