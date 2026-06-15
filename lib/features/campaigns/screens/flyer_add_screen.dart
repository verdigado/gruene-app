import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/app_settings.dart';
import 'package:gruene_app/app/utils/campaign.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_create_model.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/enhanced_wheel_slider.dart';
import 'package:gruene_app/features/campaigns/widgets/save_cancel_on_create_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class FlyerAddScreen extends StatefulWidget {
  final LatLng location;
  final AddressModel address;

  const FlyerAddScreen({super.key, required this.location, required this.address});

  @override
  State<FlyerAddScreen> createState() => _FlyerAddScreenState();
}

class _FlyerAddScreenState extends State<FlyerAddScreen> with AddressExtension, FlyerValidator {
  @override
  TextEditingController streetTextController = TextEditingController();
  @override
  TextEditingController houseNumberTextController = TextEditingController();
  @override
  TextEditingController zipCodeTextController = TextEditingController();
  @override
  TextEditingController cityTextController = TextEditingController();
  TextEditingController flyerCountTextController = TextEditingController();
  var appSettings = GetIt.I<AppSettings>();
  String _campaignName = '';

  @override
  void dispose() {
    disposeAddressTextControllers();
    flyerCountTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setAddress(widget.address);
    flyerCountTextController.text = '1';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    super.initState();
  }

  Future<void> _loadData() async {
    var activeCampaign = appSettings.campaign.activeCampaign.recentSelectedCampaignId;
    if (activeCampaign != null) {
      var campaignService = GetIt.I<GrueneApiCampaignService>();
      var campaign = await campaignService.getCampaign(activeCampaign);
      setState(() {
        _campaignName = campaign.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
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
                      t.campaigns.flyer.addFlyer,
                      style: theme.textTheme.displayMedium!.apply(color: theme.colorScheme.surface),
                    ),
                    Text(
                      _campaignName,
                      style: theme.textTheme.displayMedium!.apply(color: ThemeColors.grey200, fontSizeDelta: -4),
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
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: SizedBox()),
                Flexible(
                  child: EnhancedWheelSlider(
                    labelText: t.campaigns.flyer.countFlyer,
                    textController: flyerCountTextController,
                    labelColor: theme.colorScheme.surface,
                    sliderColor: theme.colorScheme.surface,
                    borderColor: theme.colorScheme.surface,
                    actionColor: theme.colorScheme.secondary,
                    sliderInterval: 25,
                    initialValue: 25,
                    sliderInputRange: SliderInputRange.numbers1To999,
                  ),
                ),
              ],
            ),
          ),
          SaveCancelOnCreateWidget(onSave: _onSavePressed),
          Row(
            children: [
              Icon(Icons.info_outlined, color: ThemeColors.background),
              SizedBox(width: 10),
              SizedBox(
                width: mediaQuery.size.width - 82,
                child: Text(
                  t.campaigns.flyer.info_flyer_guidelines,
                  style: theme.textTheme.labelMedium!.apply(
                    color: ThemeColors.background,
                    fontWeightDelta: 3,
                    letterSpacingDelta: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSavePressed(BuildContext localContext) {
    if (!localContext.mounted) return;
    final validationResult = validateFlyer(flyerCountTextController.text, context);
    if (validationResult == null) return;
    Navigator.maybePop(
      context,
      FlyerCreateModel(
        location: widget.location,
        address: getAddress(),
        flyerCount: validationResult.flyerCount,
        campaignId: getCurrentCampaignId()!,
      ),
    );
  }
}
