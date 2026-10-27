import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

Future<List<CalendarEvent>> getEvents(DateTimeRange dateRange) async => getFromApi(
  request: (api) => api.v1CalendarsEventsGet(
    selection: CalendarSelection.central,
    start: dateRange.start.toIso8601String(),
    end: dateRange.end.toIso8601String(),
  ),
  map: (result) => result.data.events,
);

Future<List<Calendar>> getCalendars() async => getFromApi(
  request: (api) => api.v1CalendarsGet(selection: CalendarSelection.central),
  map: (result) => result.data,
);

Future<CalendarEvent> createEvent(Calendar calendar, CreateCalendarEvent event) async => postToApi(
  request: (api) => api.v1CalendarsCalendarIdPost(calendarId: calendar.id, body: event),
  map: (result) => result,
);

Future<CalendarEvent> updateEvent(CalendarEvent event, UpdateCalendarEvent updateEvent) async => postToApi(
  request: (api) =>
      api.v1CalendarsCalendarIdEventIdPatch(calendarId: event.calendarId, eventId: event.id, body: updateEvent),
  map: (result) => result,
);

Future<CalendarEvent> deleteEvent(CalendarEvent event) async => deleteFromApi(
  request: (api) => api.v1CalendarsCalendarIdEventIdDelete(calendarId: event.calendarId, eventId: event.id),
  map: (result) => result,
);

Future<CalendarEvent> uploadEventImage(CalendarEvent event, MultipartFile image) async => getFromApi(
  request: (api) =>
      api.v1CalendarsCalendarIdEventIdImagePut(calendarId: event.calendarId, eventId: event.id, image: image),
  map: (result) => result,
);

Future<CalendarEvent> deleteEventImage(CalendarEvent event) async => deleteFromApi(
  request: (api) => api.v1CalendarsCalendarIdEventIdImageDelete(calendarId: event.calendarId, eventId: event.id),
  map: (data) => data,
);

Future<CalendarEvent> updateEventAttendance(
  CalendarEvent event,
  CalendarEventAttendanceStatus? attendanceStatus,
) async => getFromApi(
  request: (api) => api.v1CalendarsCalendarIdEventIdAttendancePut(
    calendarId: event.calendarId,
    eventId: event.id,
    body: UpdateCalendarEventAttendance(status: attendanceStatus),
  ),
  map: (result) => result,
);
