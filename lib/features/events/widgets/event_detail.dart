import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/page_info.dart';
import 'package:gruene_app/features/events/bloc/event_bloc.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_attendance_selection.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class EventDetail extends StatelessWidget {
  final CalendarEvent event;
  final Calendar calendar;
  final DateTime? recurrence;

  const EventDetail({super.key, required this.event, required this.recurrence, required this.calendar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = event.description;
    final formattedRrule = event.formattedRrule;
    final locationAddress = event.locationAddress;
    final locationUrl = event.locationUrl;
    final attendanceStatus = event.attendanceStatus;
    final groupedAttendees = event.attendees.groupBy((attendee) => attendee.status);
    final accepted = groupedAttendees[CalendarEventAttendanceStatus.accepted]?.length ?? 0;
    final tentative = groupedAttendees[CalendarEventAttendanceStatus.tentative]?.length ?? 0;
    final declined = groupedAttendees[CalendarEventAttendanceStatus.declined]?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(event.title, style: theme.textTheme.titleLarge),
        if (event.categories.isNotEmpty) Text(event.categories.join(', ')),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageInfo(icon: Icons.today, text: event.formattedDate(recurrence)),
            if (formattedRrule != null) PageInfo(icon: Icons.repeat, text: formattedRrule),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (locationAddress != null)
              PageInfo(icon: Icons.location_on_outlined, text: locationAddress, url: event.locationGeoUrl),
            if (locationUrl != null) PageInfo(icon: Icons.videocam_outlined, url: locationUrl),
          ],
        ),
        if (event.url != null) PageInfo(icon: Icons.link, url: event.url),
        PageInfo(
          icon: Icons.people,
          text: '$accepted ${t.events.accepted}, $tentative ${t.common.maybe}, $declined ${t.events.declined}',
          onPress: accepted > 0
              ? () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(t.events.accepted),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: event.attendees.length,
                        itemBuilder: (context, index) => Text(event.attendees[index].name),
                      ),
                    ),
                    actions: [TextButton(onPressed: Navigator.of(context).pop, child: Text(t.common.actions.close))],
                  ),
                )
              : null,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.events.attend),
            EventAttendanceSelection(
              attendanceStatus: attendanceStatus != null ? {attendanceStatus} : {},
              setAttendanceStatus: (attendanceStatus) async => await tryAndNotify(
                function: () async {
                  final updatedEvent = await updateEventAttendance(event, attendanceStatus.firstOrNull);
                  if (context.mounted) {
                    context.read<EventsBloc>().add(AddOrUpdateEvent(calendarEvent: updatedEvent));
                  }
                },
                context: context,
                successMessage: t.common.saved,
              ),
            ),
          ],
        ),
        if (description != null) Text(description),
        Text(t.common.updatedAt(date: event.updatedAt.formattedDate), style: theme.textTheme.labelSmall),
      ],
    );
  }
}
