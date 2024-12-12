import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/flyer/flyer_update_model.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/screens/screen_extensions.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/delete_and_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/enhanced_wheel_slider.dart';
import 'package:gruene_app/i18n/translations.g.dart';

typedef OnSaveFlyerCallback = Future<void> Function(FlyerUpdateModel flyerUpdate);

class FlyerEdit extends StatefulWidget {
  final FlyerDetailModel flyer;
  final OnSaveFlyerCallback onSave;
  final OnDeletePoiCallback onDelete;

  const FlyerEdit({super.key, required this.flyer, required this.onSave, required this.onDelete});

  @override
  State<FlyerEdit> createState() => _FlyerEditState();
}

class _FlyerEditState extends State<FlyerEdit> with AddressExtension, FlyerValidator, ConfirmDelete {
  @override
  TextEditingController streetTextController = TextEditingController();
  @override
  TextEditingController houseNumberTextController = TextEditingController();
  @override
  TextEditingController zipCodeTextController = TextEditingController();
  @override
  TextEditingController cityTextController = TextEditingController();

  TextEditingController flyerCountTextController = TextEditingController();

  @override
  void dispose() {
    disposeAddressTextControllers();
    super.dispose();
  }

  @override
  void initState() {
    setAddress(widget.flyer.address);
    flyerCountTextController.text = widget.flyer.flyerCount.toString();
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
            child: CloseSaveWidget(onSave: _saveFlyer, onClose: _closeDialog),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [Text(t.campaigns.flyer.editFlyer, style: theme.textTheme.titleLarge)],
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
                Expanded(
                  child: SizedBox(),
                ),
                Flexible(
                  child: EnhancedWheelSlider(
                    labelText: t.campaigns.flyer.countFlyer,
                    textController: flyerCountTextController,
                    initialValue: widget.flyer.flyerCount,
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
              onSave: _saveFlyer,
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
    widget.onDelete(widget.flyer.id);
    _closeDialog();
  }

  void _saveFlyer() async {
    if (!context.mounted) return;
    final validationResult = validateFlyer(flyerCountTextController.text, context);
    if (validationResult == null) return;

    final updateModel = FlyerUpdateModel(
      id: widget.flyer.id,
      address: getAddress(),
      flyerCount: validationResult.flyerCount,
    );
    await widget.onSave(updateModel);
    _closeDialog();
  }
}
