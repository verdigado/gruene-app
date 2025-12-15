import 'package:flutter/material.dart';
import 'package:gruene_app/app/location/determine_position.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/widgets/small_button_spinner.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CampaignLocationIcon extends StatelessWidget {
  final LocationStatus? locationStatus;
  final bool followUserLocation;

  const CampaignLocationIcon({super.key, required this.locationStatus, required this.followUserLocation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (locationStatus == null) {
      return const SmallButtonSpinner();
    }

    final bool hasLocationPermission =
        locationStatus == LocationStatus.always || locationStatus == LocationStatus.whileInUse;
    if (hasLocationPermission) {
      return Icon(
        followUserLocation ? Icons.my_location_outlined : Icons.location_searching_outlined,
        color: theme.colorScheme.secondary,
      );
    }

    return Icon(Icons.location_disabled_outlined, color: theme.colorScheme.error);
  }
}

class CampaignLocationButton extends StatefulWidget {
  final Future<void> Function(RequestedPosition) bringCameraToUser;
  final bool followUserLocation;

  const CampaignLocationButton({super.key, required this.bringCameraToUser, required this.followUserLocation});

  @override
  State<StatefulWidget> createState() {
    return _LocationButtonState();
  }
}

class _LocationButtonState extends State<CampaignLocationButton> {
  LocationStatus? _locationStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkAndRequestLocationPermission(context, requestIfNotGranted: false).then(
        (status) => setState(() {
          _locationStatus = status;
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Makes sure that the FAB has
      // has a padding to the right
      // screen edge
      padding: const EdgeInsets.only(right: 16),
      child: FloatingActionButton(
        // heroTag: 'fab_map_view',
        elevation: 1,
        backgroundColor: ThemeColors.textDisabled.withAlpha(150),
        onPressed: _locationStatus != null ? () => _determinePosition() : null,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: CampaignLocationIcon(locationStatus: _locationStatus, followUserLocation: widget.followUserLocation),
        ),
      ),
    );
  }

  void _showFeatureDisabled() {
    final messengerState = ScaffoldMessenger.of(context);
    messengerState.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(t.location.locationAccessDeactivated),
        action: SnackBarAction(
          label: t.common.actions.settings,
          onPressed: () async {
            await openSettingsToGrantPermissions(context);
          },
        ),
      ),
    );
  }

  Future<void> _determinePosition() async {
    setState(() => _locationStatus = null);
    final requestedPosition = await determinePosition(context, requestIfNotGranted: true);
    if (!mounted) return;

    if (requestedPosition.locationStatus == LocationStatus.deniedForever) {
      _showFeatureDisabled();
    }

    await widget.bringCameraToUser(requestedPosition);
    if (!mounted) return;

    setState(() => _locationStatus = requestedPosition.locationStatus);
  }
}
