import 'package:flutter/material.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_location.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailsSheet extends StatelessWidget {
  final CalendarEvent event;
  final void Function() onClose;

  const EventDetailsSheet({super.key, required this.event, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = event.description;
    final image = event.image;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.events.details, style: theme.textTheme.bodyLarge),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                if (image != null) Image.network(image, width: 110, height: 150, fit: BoxFit.cover),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(formatEventDateRange(event), style: theme.textTheme.labelSmall),
                      Text(event.title, style: theme.textTheme.titleSmall),
                      EventLocation(event: event),
                      if (description != null) Text(description),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
