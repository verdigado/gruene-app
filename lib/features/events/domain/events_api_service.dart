import 'package:gruene_app/app/services/gruene_api_core.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

Future<List<CalendarEvent>> getEvents() async =>
    getFromApi(request: (api) => api.v1CalendarsEventsGet(), map: (result) => result.data.events);

Future<CalendarEvent?> getEventById(String eventId) async => getFromApi(
  request: (api) => api.v1CalendarsEventsGet(),
  map: (result) => result.data.events.firstWhereOrNull((event) => event.id == eventId),
);
