import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

class EventApiService extends BaseApiService {
  Future<List<CalendarEvent>> getEvents(DateTimeRange dateRange) async => send(
    request: (api) => api.v1CalendarsEventsGet(
      selection: CalendarSelection.central,
      start: dateRange.start.toIso8601String(),
      end: dateRange.end.toIso8601String(),
    ),
    map: (result) => result.data.events,
  );

  Future<List<Calendar>> getCalendars() async => send(
    request: (api) => api.v1CalendarsGet(selection: CalendarSelection.central),
    map: (result) => result.data,
  );

  Future<CalendarEvent> createEvent(Calendar calendar, CreateCalendarEvent event) async => send(
    request: (api) => api.v1CalendarsCalendarIdPost(calendarId: calendar.id, body: event),
  );

  Future<CalendarEvent> updateEvent(CalendarEvent event, UpdateCalendarEvent updateEvent) async => send(
    request: (api) =>
        api.v1CalendarsCalendarIdEventIdPatch(calendarId: event.calendarId, eventId: event.id, body: updateEvent),
  );

  Future<CalendarEvent> deleteEvent(CalendarEvent event) async => send(
    request: (api) => api.v1CalendarsCalendarIdEventIdDelete(calendarId: event.calendarId, eventId: event.id),
  );

  Future<CalendarEvent> uploadEventImage(CalendarEvent event, MultipartFile image) async => send(
    request: (api) =>
        api.v1CalendarsCalendarIdEventIdImagePut(calendarId: event.calendarId, eventId: event.id, image: image),
  );

  Future<CalendarEvent> deleteEventImage(CalendarEvent event) async => send(
    request: (api) => api.v1CalendarsCalendarIdEventIdImageDelete(calendarId: event.calendarId, eventId: event.id),
  );

  Future<CalendarEvent> updateEventAttendance(
    CalendarEvent event,
    CalendarEventAttendanceStatus? attendanceStatus,
  ) async => send(
    request: (api) => api.v1CalendarsCalendarIdEventIdAttendancePut(
      calendarId: event.calendarId,
      eventId: event.id,
      body: UpdateCalendarEventAttendance(status: attendanceStatus),
    ),
  );
}
