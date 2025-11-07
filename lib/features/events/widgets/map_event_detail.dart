import 'package:flutter/material.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_location.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailsSheet extends StatelessWidget {
  final CalendarEvent event;

  const EventDetailsSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = event.description;
    final image = event.image;

    return Row(
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
    );
  }
}
