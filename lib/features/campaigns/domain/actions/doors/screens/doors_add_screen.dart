import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_create_model.dart';
import 'package:gruene_app/app/services/api/campaign_api_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/app/widgets/counter_input.dart';
import 'package:gruene_app/features/campaigns/domain/actions/doors/mixins.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/save_cancel_on_create_widget.dart';
import 'package:gruene_app/features/campaigns/domain/shared/mixins.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class DoorsAddScreen extends StatefulWidget {
  final LatLng location;
  final AddressModel address;

  const DoorsAddScreen({super.key, required this.location, required this.address});

  @override
  State<StatefulWidget> createState() => DoorsAddScreenState();
}

class DoorsAddScreenState extends State<DoorsAddScreen> with AddressExtension, DoorValidator {
  @override
  TextEditingController streetTextController = TextEditingController();
  @override
  TextEditingController houseNumberTextController = TextEditingController();
  @override
  TextEditingController zipCodeTextController = TextEditingController();
  @override
  TextEditingController cityTextController = TextEditingController();

  TextEditingController conversationsTextController = TextEditingController();
  TextEditingController materialOnlyTextController = TextEditingController();
  var appSettings = GetIt.I<AppSettings>();
  String _campaignName = '';

  @override
  void dispose() {
    disposeAddressTextControllers();
    conversationsTextController.dispose();
    materialOnlyTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setAddress(widget.address);
    conversationsTextController.text = '1';
    materialOnlyTextController.text = '0';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    super.initState();
  }

  Future<void> _loadData() async {
    var activeCampaign = appSettings.campaign.activeCampaign.recentSelectedCampaignId;
    if (activeCampaign != null) {
      var campaignService = GetIt.I<CampaignApiService>();
      var campaign = await campaignService.getCampaign(activeCampaign);
      setState(() {
        _campaignName = campaign.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.campaigns.door.add.title,
                      style: theme.textTheme.displayMedium!.apply(color: theme.colorScheme.surface),
                    ),
                    Text(
                      _campaignName,
                      style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.grey200),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          CreateAddressWidget(
            streetTextController: streetTextController,
            houseNumberTextController: houseNumberTextController,
            zipCodeTextController: zipCodeTextController,
            cityTextController: cityTextController,
          ),
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 6),
            child: CounterInput(
              label: t.campaigns.door.conversations,
              controller: conversationsTextController,
              foregroundColor: theme.colorScheme.surface,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: CounterInput(
              label: t.campaigns.door.materialOnly,
              controller: materialOnlyTextController,
              foregroundColor: theme.colorScheme.surface,
            ),
          ),
          SaveCancelOnCreateWidget(onSave: _onSavePressed),
        ],
      ),
    );
  }

  void _onSavePressed(BuildContext localContext) {
    if (!localContext.mounted) return;
    final validationResult = validateDoors(conversationsTextController.text, materialOnlyTextController.text, context);
    if (validationResult == null) return;
    Navigator.maybePop(
      context,
      DoorCreateModel(
        location: widget.location,
        address: getAddress(),
        conversations: validationResult.conversations,
        materialOnly: validationResult.materialOnly,
        campaignId: getCurrentCampaignId()!,
      ),
    );
  }
}
