import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_update_model.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/photo_edit_controller.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/delete_and_save_widget.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/widgets/photo_carousel.dart';
import 'package:gruene_app/features/campaigns/domain/maps/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/domain/shared/mixins.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/domain/shared/widgets/multiline_text_input_field.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/features/campaigns/helper/poster_status.dart';
import 'package:gruene_app/i18n/translations.g.dart';

typedef OnSavePosterCallback = Future<void> Function(PosterUpdateModel posterUpdate);

class PosterEdit extends StatefulWidget {
  final PosterDetailModel poster;
  final OnSavePosterCallback onSave;
  final OnDeletePoiCallback onDelete;

  const PosterEdit({super.key, required this.poster, required this.onSave, required this.onDelete});

  @override
  State<PosterEdit> createState() => _PosterEditState();
}

class _PosterEditState extends State<PosterEdit> with AddressExtension, ConfirmDelete {
  @override
  TextEditingController streetTextController = TextEditingController();
  @override
  TextEditingController houseNumberTextController = TextEditingController();
  @override
  TextEditingController zipCodeTextController = TextEditingController();
  @override
  TextEditingController cityTextController = TextEditingController();
  TextEditingController commentTextController = TextEditingController();

  bool _isWorking = false;

  late final PhotoEditController _photos;

  @override
  void dispose() {
    disposeAddressTextControllers();
    commentTextController.dispose();
    _photos.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setAddress(widget.poster.address);

    commentTextController.text = widget.poster.comment;
    _selectedPosterStatus = widget.poster.status;
    _photos = PhotoEditController(widget.poster.photos.toList()..sortByIdDescending());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lightBorderColor = ThemeColors.textLight;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: CloseSaveWidget(onClose: () => _closeDialog(ModalEditResult.cancel)),
              ),
              PhotoCarouselEditor(
                controller: _photos,
                deleteConfirmationText: t.campaigns.poster.photoDeleteConfirmation,
                currentPhotoLabel: t.campaigns.poster.currentPhotoLabel,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [Text(t.campaigns.poster.edit.title, style: theme.textTheme.titleLarge)]),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '* ${widget.poster.createdAt}',
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
                height: 217,
                child: RadioGroup(
                  groupValue: _selectedPosterStatus,
                  onChanged: (value) => setState(() => _selectedPosterStatus = value!),
                  child: Column(children: [...PosterStatusHelper.getPosterStatusList.map(_getRadioItem)]),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                height: 148,
                child: Row(
                  children: [
                    Expanded(
                      child: MultiLineTextInputField(
                        labelText: t.campaigns.poster.comment.label,
                        hint: t.campaigns.poster.comment.hint,
                        textController: commentTextController,
                        borderColor: lightBorderColor,
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
                      child: Text(
                        t.campaigns.poster.delete.hint,
                        style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 6, bottom: 24),
                child: DeleteAndSaveWidget(
                  onDelete: () => confirmDelete(context, onDeletePressed: _onDeletePressed),
                  onSave: _savePoster,
                ),
              ),
            ],
          ),
        ),
        _getLoadingScreen(),
      ],
    );
  }

  void _onDeletePressed() async {
    await widget.onDelete(widget.poster.id);
    _closeDialog(ModalEditResult.delete);
  }

  void _closeDialog(ModalEditResult editResult) {
    Navigator.maybePop(context, editResult);
  }

  void _savePoster() async {
    if (!context.mounted) return;

    setState(() {
      _isWorking = true;
    });

    final newPhotos = await _photos.prepareNewPhotos();

    final updateModel = widget.poster.toPosterUpdate().copyWith(
      address: getAddress(),
      status: _selectedPosterStatus,
      comment: commentTextController.text,
      location: widget.poster.location,
      deletedPhotoIds: _photos.deletedPhotoIds,
      newPhotos: newPhotos,
    );
    await widget.onSave(updateModel);

    _closeDialog(ModalEditResult.save);
  }

  Widget _getLoadingScreen() {
    if (!_isWorking) return SizedBox(height: 0, width: 0);
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(color: ThemeColors.text.withAlpha(120)),
        child: Center(child: CircularProgressIndicator(color: ThemeColors.primary)),
      ),
    );
  }

  PosterModelStatus _selectedPosterStatus = PosterModelStatus.ok;

  Widget _getRadioItem((PosterModelStatus, String) item) {
    var theme = Theme.of(context);
    return RadioListTile<PosterModelStatus>(
      value: item.$1,
      fillColor: WidgetStatePropertyAll(ThemeColors.primary),
      title: Text(item.$2, style: theme.textTheme.bodyMedium),
      visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity, horizontal: VisualDensity.minimumDensity),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
