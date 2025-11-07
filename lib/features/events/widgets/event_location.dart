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
    final locationAddress = event.locationAddress;
    final locationUrl = event.locationUrl;

    if (locationAddress == null && locationUrl == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (locationAddress != null) Text(locationAddress),
        if (locationUrl != null)
          Row(
            spacing: 4,
            children: [
              Text(t.events.url),
              InkWell(
                child: Text(
                  locationUrl,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ThemeColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: () => openUrl(locationUrl, context),
              ),
            ],
          ),
      ],
    );
  }
}
