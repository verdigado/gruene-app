import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/constants/map.dart';
import 'package:gruene_app/app/location/determine_position.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/map.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/full_screen_dialog.dart';
import 'package:gruene_app/app/widgets/location_button.dart';
import 'package:gruene_app/app/widgets/map_attribution.dart';
import 'package:gruene_app/app/widgets/modal_bottom_sheet.dart';
import 'package:gruene_app/features/events/bloc/events_bloc.dart';
import 'package:gruene_app/features/events/constants/index.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/features/events/widgets/event_card.dart';
import 'package:gruene_app/features/events/widgets/event_detail.dart';
import 'package:gruene_app/features/events/widgets/event_edit_dialog.dart';
import 'package:gruene_app/features/events/widgets/events_filter_dialog.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const double userZoom = 10;
const double minDistance = 0.4;

class EventsMap extends StatefulWidget {
  final List<Calendar> calendars;

  const EventsMap({super.key, required this.calendars});

  @override
  State<EventsMap> createState() => _EventsMapState();
}

class _EventsMapState extends State<EventsMap> {
  MapLibreMapController? mapController;
  bool followUserLocation = false;

  @override
  void dispose() {
    mapController?.onFeatureTapped.clear();
    mapController = null;
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    if (mapController != null) {
      mapController!.onFeatureTapped.add(_onFeatureTapped);
      await addImageFromAsset(mapController!, 'eventIcon', 'assets/symbols/events/event.png');
      if (mounted) {
        await _addEventsLayer(context);
      }
    }
  }

  Future<void> _onFeatureTapped(_, math.Point<double> point, LatLng coordinates, String layer) async {
    final features = await mapController!.queryRenderedFeatures(point, ['events-layer'], null);
    final eventIds = features.map((feature) => feature['properties']['eventId'] as String?).nonNulls.toList();

    eventIds.sort((a, b) => a.compareTo(b));

    if (mounted && eventIds.isNotEmpty) {
      _showBottomSheet(eventIds: eventIds, calendars: widget.calendars, context: context);
    }
  }

  Future<void> _addEventsLayer(BuildContext context) async {
    final events = context.read<EventsBloc>().state.events;
    await mapController?.addGeoJsonSource(eventsSourceName, events.featureCollection.toJson());
    await mapController?.addLayer(
      eventsSourceName,
      eventsLayerName,
      const SymbolLayerProperties(iconImage: 'eventIcon', iconSize: 0.2, iconAllowOverlap: true),
    );
  }

  Future<void> _updateEventsLayer(List<CalendarEvent> events) async {
    final featureCollection = events.featureCollection;
    await mapController?.setGeoJsonSource(eventsSourceName, featureCollection.toJson());

    final bounds = featureCollection.bounds;
    if (bounds != null) {
      final southwest = bounds.southwest;
      final northeast = bounds.northeast;
      if (northeast.latitude - southwest.latitude < minDistance &&
          northeast.longitude - southwest.longitude < minDistance) {
        final center = LatLng(
          (southwest.latitude + northeast.latitude) / 2,
          (southwest.longitude + northeast.longitude) / 2,
        );
        await mapController?.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: center, bearing: 0, tilt: 0, zoom: userZoom)),
        );
      } else {
        await mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, left: 20, top: 100, right: 20, bottom: 100),
        );
      }
    }
  }

  Future<void> _bringCameraToUser(RequestedPosition positionRequest) async {
    final position = positionRequest.position;
    if (position == null) return;

    setState(() => followUserLocation = true);
    final cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(position.latitude, position.longitude), bearing: 0, tilt: 0, zoom: userZoom),
    );
    await mapController?.animateCamera(cameraUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = GetIt.I<AppSettings>();
    final cameraPosition = CameraPosition(
      target: appSettings.events?.lastPosition ?? germanyCenter,
      zoom: appSettings.events?.lastZoomLevel ?? germanyZoom,
    );

    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) => _updateEventsLayer(state.events),
      child: Stack(
        children: [
          MapLibreMap(
            styleString: Config.maplibreUrl,
            initialCameraPosition: cameraPosition,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            cameraTargetBounds: CameraTargetBounds(germanyBounds),
            minMaxZoomPreference: zoomPreference,
            compassEnabled: false,
            trackCameraPosition: true,
            myLocationEnabled: true,
            myLocationTrackingMode: followUserLocation ? MyLocationTrackingMode.tracking : MyLocationTrackingMode.none,
            onCameraTrackingDismissed: () => setState(() => followUserLocation = false),
            onCameraIdle: () {
              appSettings.events = (
                lastPosition: mapController!.cameraPosition!.target,
                lastZoomLevel: mapController!.cameraPosition!.zoom,
              );
            },
            // Replace with custom map attribution
            attributionButtonMargins: const math.Point(-100, -100),
          ),
          Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 0), child: EventsFilterBar()),
          MapAttribution(),
          Positioned(
            bottom: 16,
            right: 16,
            child: LocationButton(bringCameraToUser: _bringCameraToUser, followUserLocation: followUserLocation),
          ),
        ],
      ),
    );
  }
}

Future<void> _showBottomSheet({
  required List<String> eventIds,
  required BuildContext context,
  required List<Calendar> calendars,
}) async {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      String? selectedEventId;
      return StatefulBuilder(
        builder: (context, setState) => BlocBuilder<EventsBloc, EventsState>(
          builder: (context, state) {
            final events = state.events.where((event) => eventIds.contains(event.id)).toList();
            final event = events.length == 1
                ? events[0]
                : events.firstWhereOrNull((event) => event.id == selectedEventId);
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
                          heroTag: 'edit event',
                          onPressed: () =>
                              showFullScreenDialog(context, (_) => EventEditDialog(calendar: calendar, event: event)),
                          child: Icon(Icons.edit),
                        ),
                      ),
                    )
                  : null,
              child: event != null && calendar != null
                  ? EventDetail(event: event, recurrence: null, calendar: calendar)
                  : Column(
                      children: events
                          .map(
                            (event) => EventCard(
                              event: event,
                              recurrence: null,
                              onTap: () => setState(() => selectedEventId = event.id),
                            ),
                          )
                          .toList(),
                    ),
            );
          },
        ),
      );
    },
  );
}
