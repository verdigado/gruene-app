import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/doors/door_update_model.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/delete_and_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/enhanced_wheel_slider.dart';
import 'package:gruene_app/i18n/translations.g.dart';

typedef OnSaveDoorCallback = Future<void> Function(DoorUpdateModel doorUpdate);

class DoorEdit extends StatefulWidget {
  final DoorDetailModel door;
  final OnSaveDoorCallback onSave;
  final OnDeletePoiCallback onDelete;

  const DoorEdit({
    super.key,
    required this.door,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<DoorEdit> createState() => _DoorEditState();
}

class _DoorEditState extends State<DoorEdit> with AddressExtension, DoorValidator, ConfirmDelete {
  @override
  TextEditingController streetTextController = TextEditingController();
  @override
  TextEditingController houseNumberTextController = TextEditingController();
  @override
  TextEditingController zipCodeTextController = TextEditingController();
  @override
  TextEditingController cityTextController = TextEditingController();

  TextEditingController closedDoorTextController = TextEditingController();
  TextEditingController openedDoorTextController = TextEditingController();

  @override
  void dispose() {
    disposeAddressTextControllers();
    super.dispose();
  }

  @override
  void initState() {
    streetTextController.text = widget.door.address.street;
    houseNumberTextController.text = widget.door.address.houseNumber;
    zipCodeTextController.text = widget.door.address.zipCode;
    cityTextController.text = widget.door.address.city;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lightBorderColor = ThemeColors.textLight;
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: CloseSaveWidget(onClose: _closeDialog),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [Text(t.campaigns.door.editDoor, style: theme.textTheme.titleLarge)],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '* ${widget.door.createdAt}',
              style: theme.textTheme.labelMedium!.apply(color: ThemeColors.textDisabled),
            ),
          ),
          CreateAddressWidget(
            streetTextController: streetTextController,
            houseNumberTextController: houseNumberTextController,
            zipCodeTextController: zipCodeTextController,
            cityTextController: cityTextController,
            inputBorderColor: lightBorderColor,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Flexible(
                  child: EnhancedWheelSlider(
                    labelText: t.campaigns.door.closedDoors,
                    textController: closedDoorTextController,
                    initialValue: widget.door.closedDoors,
                    labelColor: ThemeColors.textDisabled,
                    sliderColor: ThemeColors.text,
                    borderColor: lightBorderColor,
                    actionColor: theme.colorScheme.secondary,
                    sliderInputRange: SliderInputRange.numbers0To999,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: EnhancedWheelSlider(
                    labelText: t.campaigns.door.openedDoors,
                    initialValue: widget.door.openedDoors,
                    textController: openedDoorTextController,
                    labelColor: ThemeColors.textDisabled,
                    sliderColor: ThemeColors.text,
                    borderColor: lightBorderColor,
                    actionColor: theme.colorScheme.secondary,
                    sliderInputRange: SliderInputRange.numbers0To999,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 6, bottom: 24),
            child: DeleteAndSaveWidget(
              onDelete: () => confirmDelete(context, _onDeletePressed),
              onSave: _saveDoor,
            ),
          ),
        ],
      ),
    );
  }

  void _closeDialog() {
    Navigator.maybePop(context);
  }

  void _onDeletePressed() {
    widget.onDelete(widget.door.id);
    _closeDialog();
  }

  void _saveDoor() async {
    if (!context.mounted) return;
    final validationResult = validateDoors(openedDoorTextController.text, closedDoorTextController.text, context);
    if (validationResult == null) return;

    final updateModel = DoorUpdateModel(
      id: widget.door.id,
      address: getAddress(),
      openedDoors: validationResult.openedDoors,
      closedDoors: validationResult.closedDoors,
      location: widget.door.location,
      oldDoorDetail: widget.door,
    );
    await widget.onSave(updateModel);
    _closeDialog();
  }
}
