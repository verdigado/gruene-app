import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/widgets/event_detail.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailScreen extends StatefulWidget {
  final CalendarEvent event;
  final Calendar calendar;
  final DateTime recurrence;

  const EventDetailScreen({super.key, required this.event, required this.calendar, required this.recurrence});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late CalendarEvent event;
  late DateTime recurrence;
  late Calendar calendar;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    recurrence = widget.recurrence;
    calendar = widget.calendar;
  }

  @override
  Widget build(BuildContext context) {
    final image = event.image;

    return Scaffold(
      appBar: MainAppBar(
        title: t.events.events,
        appBarAction: !calendar.readOnly
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  final deleted = await showEventDeleteDialog(context, event);
                  if (deleted == true && context.mounted) {
                    Navigator.of(context).pop(null);
                  }
                },
              )
            : null,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => !didPop ? Navigator.of(context).pop(event) : null,
        child: ExpandingScrollView(
          children: [
            if (image != null) Image.network(image, width: double.infinity, fit: BoxFit.fitWidth),
            Padding(
              padding: const EdgeInsets.all(20),
              child: EventDetail(
                event: event,
                recurrence: recurrence,
                calendar: calendar,
                update: (event) => setState(() => this.event = event),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDeletionConfirmationDialog extends StatelessWidget {
  final CalendarEvent event;

  const EventDeletionConfirmationDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.events.delete),
      content: Text(t.events.deleteDescription),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(t.common.actions.cancel)),
        TextButton(
          child: Text(t.common.actions.delete),
          onPressed: () async {
            final result = await tryAndNotify(
              function: () => deleteEvent(event),
              context: context,
              successMessage: t.events.deleted,
            );
            if (context.mounted) {
              Navigator.of(context).pop(result != null);
            }
          },
        ),
      ],
    );
  }
}

Future<bool?> showEventDeleteDialog(BuildContext context, CalendarEvent event) => showDialog<bool>(
  context: context,
  builder: (BuildContext context) => EventDeletionConfirmationDialog(event: event),
);
