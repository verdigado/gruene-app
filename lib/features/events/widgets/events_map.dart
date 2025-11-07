import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/location/determine_position.dart';
import 'package:gruene_app/app/screens/future_loading_screen.dart';
import 'package:gruene_app/app/utils/map.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/map_attribution.dart';
import 'package:gruene_app/features/events/widgets/event_detail_sheet.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class EventsMap extends StatefulWidget {
  final List<CalendarEvent> events;

  const EventsMap({super.key, required this.events});

  @override
  State<EventsMap> createState() => _EventsMapState();
}

class _EventsMapState extends State<EventsMap> {
  MapLibreMapController? mapController;

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    if (!mounted || mapController == null) return;

    await addImageFromAsset(mapController!, 'eventIcon', 'assets/symbols/events/event.png');
    await _addMarkers();

    mapController?.onSymbolTapped.add((symbol) {
      if (!mounted) return;
      final eventId = symbol.data?['eventId'];
      final event = widget.events.firstWhereOrNull((event) => event.id == eventId);

      if (event != null) {
        showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          builder: (context) => EventDetailsSheet(event: event, onClose: () => Navigator.pop(context)),
        );
      }
    });
  }

  Future<void> _addMarkers() async {
    for (final event in widget.events) {
      final coords = event.coords;
      if (coords == null || coords.length != 2) continue;
      if (!mounted) return;

      await mapController?.addSymbol(
        SymbolOptions(geometry: LatLng(coords[0], coords[1]), iconImage: 'eventIcon', iconSize: 0.15),
        {'eventId': event.id},
      );
    }
  }

  @override
  void dispose() {
    mapController?.onSymbolTapped.clear();
    mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureLoadingScreen(
      load: () => determinePosition(
        context,
        requestIfNotGranted: true,
        preferLastKnownPosition: true,
      ).timeout(const Duration(milliseconds: 400), onTimeout: RequestedPosition.unknown),
      buildChild: (RequestedPosition? requestedPosition, _) {
        final position = requestedPosition?.toLatLng();
        final cameraPosition = position != null
            ? CameraPosition(target: position, zoom: 12)
            : CameraPosition(target: Config.centerGermany, zoom: Config.germanyZoom);

        return Stack(
          children: [
            MapLibreMap(
              styleString: Config.maplibreUrl,
              initialCameraPosition: cameraPosition,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
              // Replace with custom map attribution
              attributionButtonMargins: const Point(-100, -100),
            ),
            MapAttribution(),
          ],
        );
      },
    );
  }
}
