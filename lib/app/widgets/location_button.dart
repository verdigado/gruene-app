import 'package:flutter/material.dart';
import 'package:gruene_app/app/location/determine_position.dart';
import 'package:gruene_app/features/campaigns/widgets/small_button_spinner.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class LocationIcon extends StatelessWidget {
  final RequestedPosition? requestedPosition;
  final bool followUserLocation;

  const LocationIcon({super.key, required this.requestedPosition, required this.followUserLocation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (requestedPosition == null) {
      return const SmallButtonSpinner();
    }

    if ([LocationStatus.always, LocationStatus.whileInUse].contains(requestedPosition?.locationStatus)) {
      return Icon(
        requestedPosition?.position == null || followUserLocation
            ? Icons.my_location_outlined
            : Icons.location_searching_outlined,
        color: theme.colorScheme.primary,
      );
    }

    return Icon(Icons.location_disabled_outlined, color: theme.colorScheme.error);
  }
}

class LocationButton extends StatefulWidget {
  final Future<void> Function(RequestedPosition) bringCameraToUser;
  final bool followUserLocation;

  const LocationButton({super.key, required this.bringCameraToUser, required this.followUserLocation});

  @override
  State<StatefulWidget> createState() {
    return _LocationButtonState();
  }
}

class _LocationButtonState extends State<LocationButton> {
  RequestedPosition? _requestedPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _determinePosition(context));
  }

  @override
  Widget build(BuildContext context) {
    final requestedPosition = _requestedPosition;
    return FloatingActionButton.small(
      heroTag: 'location',
      onPressed: () => requestedPosition == null || requestedPosition.position == null
          ? _determinePosition(context)
          : widget.bringCameraToUser(requestedPosition),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: LocationIcon(requestedPosition: requestedPosition, followUserLocation: widget.followUserLocation),
      ),
    );
  }

  void _showFeatureDisabled(BuildContext context) {
    final messengerState = ScaffoldMessenger.of(context);
    messengerState.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(t.location.locationAccessDeactivated),
        action: SnackBarAction(
          label: t.common.actions.settings,
          onPressed: () => openSettingsToGrantPermissions(context),
        ),
      ),
    );
  }

  Future<void> _determinePosition(BuildContext context) async {
    setState(() => _requestedPosition = null);
    final requestedPosition = await determinePosition(
      context,
      requestIfNotGranted: true,
    ).timeout(const Duration(seconds: 20), onTimeout: RequestedPosition.unknown);
    setState(() => _requestedPosition = requestedPosition);

    if (context.mounted && requestedPosition.locationStatus == LocationStatus.deniedForever) {
      _showFeatureDisabled(context);
    }

    await widget.bringCameraToUser(requestedPosition);
  }
}
