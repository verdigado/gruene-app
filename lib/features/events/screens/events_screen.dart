import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/widgets/events_list.dart';
import 'package:gruene_app/features/events/widgets/events_map.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool isMapView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.events.events),
      body: FutureLoadingScreen(
        load: getEvents,
        buildChild: (data, _) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          // Hide past events (only show events that start or end today or in the future)
          final relevantEvents = data
              .where((event) => event.end == null ? event.start.isAfter(today) : event.end!.isAfter(today))
              .toList();
          return Stack(
            children: [
              Positioned.fill(
                child: isMapView ? EventsMap(events: relevantEvents) : EventsList(events: relevantEvents),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: SegmentedButton(
                    segments: [
                      ButtonSegment(value: false, icon: const Icon(Icons.list), label: Text(t.events.list)),
                      ButtonSegment(value: true, icon: const Icon(Icons.map), label: Text(t.events.map)),
                    ],
                    selected: {isMapView},
                    onSelectionChanged: (newSelection) => setState(() => isMapView = newSelection.first),
                    showSelectedIcon: false,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
