import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/services/api/event_api_service.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/alert.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/expanding_scroll_view.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/full_width_image.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
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
        title: t.events.title,
        appBarAction: !calendar.readOnly
            ? IconButton(icon: Icon(Icons.delete), onPressed: () => showEventDeleteDialog(context, event))
            : null,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            ExpandingScrollView(
              padding: const EdgeInsets.all(0),
              children: [
                if (image != null) FullWidthImage(image: image),
                Padding(
                  padding: screenPadding,
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

Future<void> showEventDeleteDialog(BuildContext context, CalendarEvent event) => showConfirmationDialog(
  context,
  title: t.events.delete,
  label: t.common.actions.delete,
  content: Text(t.events.deleteDescription),
  onConfirmed: () => tryAndNotify(
    function: () async {
      await GetIt.I<EventApiService>().deleteEvent(event);
      if (context.mounted) {
        Navigator.of(context).pop();
        context.read<EventsBloc>().add(DeleteEvent(calendarEvent: event));
      }
    },
    context: context,
    onSuccess: (context, _) => showSnackBar(context: context, text: t.events.deleted),
  ),
);
