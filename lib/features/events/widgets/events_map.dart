import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/location/determine_position.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/map.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/map_attribution.dart';
import 'package:gruene_app/app/widgets/modal_bottom_sheet.dart';
import 'package:gruene_app/features/campaigns/helper/app_settings.dart';
import 'package:gruene_app/features/events/constants/index.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_card.dart';
import 'package:gruene_app/features/events/widgets/event_detail.dart';
import 'package:gruene_app/features/events/widgets/event_edit_dialog.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/along.dart';

const double userZoom = 10;

class EventsMap extends StatefulWidget {
  final void Function(CalendarEvent) update;
  final List<CalendarEvent> events;
  final List<Calendar> calendars;
  final String? initialEventId;

  const EventsMap({
    super.key,
    required this.events,
    this.initialEventId,
    required this.calendars,
    required this.update,
  });

  @override
  State<EventsMap> createState() => _EventsMapState();
}

class _EventsMapState extends State<EventsMap> {
  MapLibreMapController? mapController;

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    if (mapController != null) {
      mapController!.onFeatureTapped.add(_onFeatureTapped);
      await addImageFromAsset(mapController!, 'eventIcon', 'assets/symbols/events/event.png');
      await _addEventsLayer();
    }
  }

  Future<void> _onFeatureTapped(_, math.Point<double> point, LatLng coordinates, String layer) async {
    final features = await mapController!.queryRenderedFeatures(point, ['events-layer'], null);
    final events = features
        .map((feature) => widget.events.firstWhereOrNull((event) => event.id == feature['properties']['eventId']))
        .nonNulls
        .toList();

    if (mounted && events.isNotEmpty) {
      _showBottomSheet(events: events, calendars: widget.calendars, context: context, update: widget.update);
    }
  }

  Future<void> _addEventsLayer() async {
    final features = widget.events
        .where((event) => event.coords?.length == 2)
        .map(
          (event) => Feature(
            id: event.id,
            geometry: Point(coordinates: Position(event.coords![0], event.coords![1])),
            properties: {'eventId': event.id},
          ),
        )
        .toList();

    await mapController?.addGeoJsonSource(eventsSourceName, FeatureCollection(features: features).toJson());
    await mapController?.addLayer(
      eventsSourceName,
      eventsLayerName,
      const SymbolLayerProperties(iconImage: 'eventIcon', iconSize: 0.2, iconAllowOverlap: true),
    );
  }

  @override
  void dispose() {
    mapController?.onFeatureTapped.clear();
    mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = GetIt.I<AppSettings>();

    return FutureLoadingScreen(
      load: () => determinePosition(
        context,
        requestIfNotGranted: true,
        preferLastKnownPosition: true,
      ).timeout(const Duration(milliseconds: 400), onTimeout: RequestedPosition.unknown),
      buildChild: (RequestedPosition? requestedPosition, _) {
        final position = requestedPosition?.toLatLng();
        final cameraPosition = position != null
            ? CameraPosition(target: position, zoom: userZoom)
            : CameraPosition(
                target: appSettings.events?.lastPosition ?? Config.centerGermany,
                zoom: appSettings.events?.lastZoomLevel ?? Config.germanyZoom,
              );

        return Stack(
          children: [
            MapLibreMap(
              styleString: Config.maplibreUrl,
              initialCameraPosition: cameraPosition,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
              trackCameraPosition: true,
              onCameraIdle: () {
                appSettings.events = (
                  lastPosition: mapController!.cameraPosition!.target,
                  lastZoomLevel: mapController!.cameraPosition!.zoom,
                );
              },
              // Replace with custom map attribution
              attributionButtonMargins: const math.Point(-100, -100),
            ),
            MapAttribution(),
          ],
        );
      },
    );
  }
}

Future<void> _showBottomSheet({
  required BuildContext context,
  required List<CalendarEvent> events,
  required List<Calendar> calendars,
  required void Function(CalendarEvent) update,
}) async {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      CalendarEvent? selectedEvent;
      return StatefulBuilder(
        builder: (context, setState) {
          final event = events.length == 1 ? events[0] : selectedEvent;
          final calendar = event?.calendar(calendars);

          return ModalBottomSheet(
            image: event?.image,
            onClose: () => Navigator.pop(context),
            aside: calendar != null && !calendar.readOnly
                ? Positioned(
                    bottom: 16,
                    right: 16,
                    child: SafeArea(
                      child: FloatingActionButton(
                        onPressed: () => showFullScreenDialog(
                          context,
                          (_) => EventEditDialog(calendar: calendar, event: event, context: context, update: update),
                        ),
                        child: Icon(Icons.edit),
                      ),
                    ),
                  )
                : null,
            child: event != null && calendar != null
                ? EventDetail(event: event, recurrence: null, calendar: calendar, update: update)
                : Column(
                    children: events
                        .map(
                          (event) => EventCard(
                            event: event,
                            recurrence: null,
                            onTap: () => setState(() => selectedEvent = event),
                          ),
                        )
                        .toList(),
                  ),
          );
        },
      );
    },
  );
}
