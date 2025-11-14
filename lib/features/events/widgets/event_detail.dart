import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/page_info.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventDetail extends StatelessWidget {
  final CalendarEvent event;
  final DateTime? recurrence;

  const EventDetail({super.key, required this.event, required this.recurrence});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = event.description;
    final formattedRrule = event.formattedRrule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(event.title, style: theme.textTheme.titleLarge),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageInfo(icon: Icons.today, text: event.formattedDate(recurrence)),
            if (formattedRrule != null) PageInfo(icon: Icons.repeat, text: formattedRrule),
          ],
        ),
        EventLocation(event: event),
        if (description != null) Text(description),
      ],
    );
  }
}

class EventLocation extends StatelessWidget {
  final CalendarEvent event;

  const EventLocation({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final locationAddress = event.locationAddress;
    final locationUrl = event.locationUrl;

    if (locationAddress == null && locationUrl == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (locationAddress != null) PageInfo(icon: Icons.location_on_outlined, text: locationAddress),
        if (locationUrl != null) PageInfo(icon: Icons.videocam_outlined, url: locationUrl),
      ],
    );
  }
}
