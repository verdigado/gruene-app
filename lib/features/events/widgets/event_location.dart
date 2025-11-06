import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/open_url.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventLocation extends StatelessWidget {
  final CalendarEvent event;

  const EventLocation({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = event.location;

    if (location == null) {
      return SizedBox.shrink();
    }

    if (event.locationType == 'online') {
      return Row(
        spacing: 4,
        children: [
          Text(t.events.url, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          InkWell(
              child: Text(location, style: theme.textTheme.bodyMedium?.copyWith(color: ThemeColors.primary, decoration: TextDecoration.underline)),
              onTap: () => openUrl(location, context),
          ),
        ],
      );
    }

    return Text(location);
  }
}
