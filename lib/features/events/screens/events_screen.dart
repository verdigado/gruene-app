import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/theme/theme.dart';
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
          return Stack(
            children: [
              Positioned.fill(
                child: isMapView ? EventsMap(events: data) : EventsList(events: data),
              ),
              Positioned(
                bottom: 50,
                left: 24,
                right: 24,
                child: Center(
                  child: SegmentedButton(
                    segments: [
                      ButtonSegment(value: false, icon: const Icon(Icons.list), label: Text(t.events.list)),
                      ButtonSegment(value: true, icon: const Icon(Icons.map), label: Text(t.events.map)),
                    ],
                    selected: {isMapView},
                    onSelectionChanged: (newSelection) => setState(() => isMapView = newSelection.first),
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected) ? ThemeColors.primary : Colors.white,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected) ? Colors.white : ThemeColors.primary,
                      ),
                      side: WidgetStateProperty.all(BorderSide(color: ThemeColors.primary, width: 1.5)),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
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
