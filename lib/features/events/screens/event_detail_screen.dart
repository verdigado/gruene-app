import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/screens/error_screen.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_detail.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart' hide Image;

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as ({CalendarEvent event, DateTime recurrence, Calendar calendar})?;

    return FutureLoadingScreen(
      loadingLayoutBuilder: (Widget child) => Scaffold(appBar: MainAppBar(title: t.events.events)),
      load: extra == null
          ? () async {
              final data = await getEventById(eventId);
              return data != null ? (event: data.event, recurrence: data.event.start, calendar: data.calendar) : null;
            }
          : () async => extra,
      buildChild: (data, extra) {
        if (data == null) {
          return ErrorScreen(errorMessage: t.events.eventNotFound, retry: () => getEventById(eventId));
        }

        final image = data.event.image;

        return Scaffold(
          appBar: MainAppBar(
            title: t.events.events,
            appBarAction: !data.calendar.readOnly
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      final success = await showEventDeleteDialog(context, data.calendar, data.event);
                      if (success == true && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  )
                : null,
          ),
          body: ExpandingScrollView(
            children: [
              if (image != null) Image.network(image, width: double.infinity, fit: BoxFit.fitWidth),
              Padding(
                padding: const EdgeInsets.all(20),
                child: EventDetail(
                  event: data.event,
                  recurrence: data.recurrence,
                  calendar: data.calendar,
                  update: (event) => extra.update((calendar: data.calendar, event: event, recurrence: event.nextDate(null))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AlertDialogWithLoadingState extends StatefulWidget {
  final Future<void> Function() load;

  const AlertDialogWithLoadingState({super.key, required this.load});

  @override
  State<AlertDialogWithLoadingState> createState() => _AlertDialogWithLoadingState();
}

class _AlertDialogWithLoadingState extends State<AlertDialogWithLoadingState> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Dialog(child: Center(child: CircularProgressIndicator()));
    }
    return AlertDialog(
      title: Text(t.events.delete),
      content: Text(t.events.deleteDescription),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(t.common.actions.cancel)),
        TextButton(
          child: Text(t.common.actions.delete),
          onPressed: () async {
            setState(() => loading = true);
            final success = await tryAndNotify(
              function: widget.load,
              context: context,
              successMessage: t.events.deleted,
              errorMessage: t.error.deletionFailed,
            );

            if (context.mounted) Navigator.of(context).pop(success);
          },
        ),
      ],
    );
  }
}

Future<bool?> showEventDeleteDialog(BuildContext context, Calendar calendar, CalendarEvent event) => showDialog<bool>(
  context: context,
  builder: (BuildContext context) => AlertDialogWithLoadingState(load: () async => await deleteEvent(calendar, event)),
);
