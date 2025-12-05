import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/full_width_image.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/widgets/event_detail.dart';
import 'package:gruene_app/features/events/widgets/event_edit_dialog.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailScreenContainer extends StatelessWidget {
  final String eventId;
  final Calendar calendar;
  final DateTime recurrence;

  const EventDetailScreenContainer({
    super.key,
    required this.eventId,
    required this.calendar,
    required this.recurrence,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) => EventDetailScreen(
        event: state.events.firstWhereOrNull((event) => event.id == eventId),
        calendar: calendar,
        recurrence: recurrence,
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final CalendarEvent? event;
  final Calendar calendar;
  final DateTime recurrence;

  const EventDetailScreen({super.key, required this.event, required this.calendar, required this.recurrence});

  @override
  Widget build(BuildContext context) {
    final event = this.event;
    if (event == null) {
      return Container();
    }

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
                    Navigator.of(context).pop();
                    context.read<EventsBloc>().add(DeleteEvent(calendarEvent: event));
                  }
                },
              )
            : null,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            ExpandingScrollView(
              children: [
                if (image != null) FullWidthImage(image: image),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: EventDetail(event: event, recurrence: recurrence, calendar: calendar),
                ),
              ],
            ),
            if (!calendar.readOnly)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'edit event',
                  onPressed: () =>
                      showFullScreenDialog(context, (_) => EventEditDialog.edit(event: event, calendar: calendar)),
                  child: Icon(Icons.edit),
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
          onPressed: () async => await tryAndNotify(
            function: () async {
              Navigator.of(context).pop(true);
              await deleteEvent(event);
            },
            context: context,
            successMessage: t.events.deleted,
          ),
        ),
      ],
    );
  }
}

Future<bool?> showEventDeleteDialog(BuildContext context, CalendarEvent event) => showDialog<bool>(
  context: context,
  builder: (_) => EventDeletionConfirmationDialog(event: event),
);
