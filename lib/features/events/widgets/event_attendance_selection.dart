import 'package:flutter/material.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

class EventAttendanceSelection extends StatelessWidget {
  final void Function(Set<CalendarEventAttendanceStatus> attendanceStatus) setAttendanceStatus;
  final Set<CalendarEventAttendanceStatus> attendanceStatus;
  final bool multiSelect;

  const EventAttendanceSelection({super.key, required this.attendanceStatus, this.multiSelect = false, required this.setAttendanceStatus});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      segments: [
        ButtonSegment(
          value: CalendarEventAttendanceStatus.accepted,
          label: Text(t.common.yes),
        ),
        ButtonSegment(
          value: CalendarEventAttendanceStatus.tentative,
          icon: CalendarEventAttendanceStatus.tentative.icon(context),
          label: Text(t.common.maybe),
        ),
        ButtonSegment(
          value: CalendarEventAttendanceStatus.declined,
          icon: CalendarEventAttendanceStatus.declined.icon(context),
          label: Text(t.common.no),
        ),
      ],
      selected: attendanceStatus,
      onSelectionChanged: setAttendanceStatus,
      multiSelectionEnabled: multiSelect,
      emptySelectionAllowed: true,
    );
  }
}
