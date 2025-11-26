import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventCard extends StatelessWidget {
  final CalendarEvent event;
  final DateTime? recurrence;
  final void Function() onTap;

  const EventCard({super.key, required this.event, required this.recurrence, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = event.locationAddress != null && event.locationUrl != null
        ? '${event.locationAddress} | ${t.events.digital}'
        : (event.locationAddress ?? event.locationUrl);
    final hasImage = event.image != null && event.image!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    color: ThemeColors.textDisabled,
                    image: hasImage ? DecorationImage(image: NetworkImage(event.image!), fit: BoxFit.cover) : null,
                  ),
                  child: !hasImage
                      ? const Center(child: Icon(Icons.calendar_today, size: 52, color: Colors.white))
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(event.formattedDate(recurrence), style: theme.textTheme.labelSmall),
                            event.attendanceStatus.icon(context, 16) ?? SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(event.title, style: theme.textTheme.titleSmall),
                        ...(location != null
                            ? [SizedBox(height: 12), Text(location, style: theme.textTheme.labelSmall)]
                            : []),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
