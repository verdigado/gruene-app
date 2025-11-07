import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/bottom_sheet/bloc/bottom_sheet_cubit.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/location/determine_position.dart';
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

    try {
      final bytes = (await rootBundle.load('assets/symbols/events/event.png')).buffer.asUint8List();
      await mapController!.addImage('eventIcon', bytes);
      await _addMarkers();

      mapController!.onSymbolTapped.add((symbol) {
        if (!mounted) return;
        final eventId = symbol.data?['eventId'];
        final event = widget.events.firstWhereOrNull((e) => e.id == eventId);

        if (event != null) {
          context.read<BottomSheetCubit>().show(
            EventDetailsSheet(
              event: event,
              onClose: () {
                if (mounted) context.read<BottomSheetCubit>().hide();
              },
            ),
          );
        }
      });
    } catch (e, st) {
      debugPrint('Error during map setup: $e\n$st');
    }
  }

  Future<void> _addMarkers() async {
    if (mapController == null) return;

    for (final event in widget.events) {
      final coords = event.coords;
      if (coords == null || coords.length != 2) continue;
      if (!mounted) return;

      await mapController!.addSymbol(
        SymbolOptions(geometry: LatLng(coords[0], coords[1]), iconImage: 'eventIcon', iconSize: 0.15),
        {'eventId': event.id},
      );
    }
  }

  @override
  void dispose() {
    try {
      mapController?.onSymbolTapped.clear();
    } catch (_) {}
    mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: determinePosition(
        context,
        requestIfNotGranted: true,
        preferLastKnownPosition: true,
      ).timeout(const Duration(milliseconds: 400), onTimeout: () => RequestedPosition.unknown()),
      builder: (context, AsyncSnapshot<RequestedPosition> snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const Center();
        }

        final position = snapshot.data!;

        return Stack(
          children: [
            MapLibreMap(
              styleString: Config.maplibreUrl,
              initialCameraPosition: position.isAvailable()
                  ? CameraPosition(target: LatLng(position.position!.latitude, position.position!.longitude), zoom: 12)
                  : CameraPosition(target: Config.centerGermany, zoom: Config.germanyZoom),
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
              attributionButtonMargins: const Point(-100, -100),
            ),
            MapAttribution(),
          ],
        );
      },
    );
  }
}
