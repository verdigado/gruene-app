import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_create_model.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/enhanced_wheel_slider.dart';
import 'package:gruene_app/features/campaigns/widgets/save_cancel_on_create_widget.dart';
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

  TextEditingController openedDoorTextController = TextEditingController();
  TextEditingController closedDoorTextController = TextEditingController();

  @override
  void dispose() {
    disposeAddressTextControllers();
    openedDoorTextController.dispose();
    closedDoorTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setAddress(widget.address);
    openedDoorTextController.text = '1';
    closedDoorTextController.text = '0';
    super.initState();
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
                child: Text(
                  t.campaigns.door.addDoor,
                  style: theme.textTheme.displayMedium!.apply(color: theme.colorScheme.surface),
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
                Flexible(
                  child: Text(
                    t.campaigns.door.createDoor.hint,
                    style: theme.textTheme.labelMedium?.apply(color: theme.colorScheme.surface),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Flexible(
                  child: EnhancedWheelSlider(
                    labelText: t.campaigns.door.closedDoors,
                    initialValue: 0,
                    textController: closedDoorTextController,
                    labelColor: theme.colorScheme.surface,
                    sliderColor: theme.colorScheme.surface,
                    borderColor: theme.colorScheme.surface,
                    actionColor: theme.colorScheme.secondary,
                    sliderInputRange: SliderInputRange.numbers0To999,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: EnhancedWheelSlider(
                    labelText: t.campaigns.door.openedDoors,
                    initialValue: 1,
                    textController: openedDoorTextController,
                    labelColor: theme.colorScheme.surface,
                    sliderColor: theme.colorScheme.surface,
                    borderColor: theme.colorScheme.surface,
                    actionColor: theme.colorScheme.secondary,
                    sliderInputRange: SliderInputRange.numbers0To999,
                  ),
                ),
              ],
            ),
          ),
          SaveCancelOnCreateWidget(onSave: _onSavePressed),
        ],
      ),
    );
  }

  void _onSavePressed(BuildContext localContext) {
    if (!localContext.mounted) return;
    final validationResult = validateDoors(openedDoorTextController.text, closedDoorTextController.text, context);
    if (validationResult == null) return;
    Navigator.maybePop(
      context,
      DoorCreateModel(
        location: widget.location,
        address: getAddress(),
        openedDoors: validationResult.openedDoors,
        closedDoors: validationResult.closedDoors,
      ),
    );
  }
}
