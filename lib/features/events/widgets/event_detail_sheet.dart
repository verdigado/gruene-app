import 'package:flutter/material.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_location.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailsSheet extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onClose;

  const EventDetailsSheet({super.key, required this.event, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.events.details, style: theme.textTheme.bodyLarge),
                Transform.translate(
                  offset: const Offset(14, 0),
                  child: IconButton(icon: const Icon(Icons.close, size: 28), onPressed: onClose),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.image != null) ...[
                  Image.network(event.image!, width: 110, height: 150, fit: BoxFit.cover),
                  const SizedBox(width: 16),
                ],

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(formatEventDateRange(event), style: theme.textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text(event.title, style: theme.textTheme.titleSmall),
                      EventLocation(event: event),
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
