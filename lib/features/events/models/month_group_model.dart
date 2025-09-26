import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class MonthGroup {
  final DateTime month;
  final List<CalendarEvent> events;

  MonthGroup({required this.month, required this.events});
}
