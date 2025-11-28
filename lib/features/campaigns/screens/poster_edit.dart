import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:gruene_app/features/campaigns/helper/poster_status.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_photo_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_update_model.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/features/campaigns/screens/mixins.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/create_address_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/delete_and_save_widget.dart';
import 'package:gruene_app/features/campaigns/widgets/multiline_text_input_field.dart';
import 'package:gruene_app/i18n/translations.g.dart';

typedef OnSavePosterCallback = Future<void> Function(PosterUpdateModel posterUpdate);

enum PhotoEditAction { acquireNewPhoto, usePhotoFromGallery }

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

  final _imageSliderController = CarouselSliderController();
  var _currentImageIndex = 0;
  late List<PosterPhotoModel> _currentPhotos;
  final List<String> _deletedPhotoIds = [];
  final List<PosterPhotoModel> _newPhotos = [];

  @override
  void dispose() {
    disposeAddressTextControllers();
    commentTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setAddress(widget.poster.address);

    commentTextController.text = widget.poster.comment;
    _selectedPosterStatus = widget.poster.status;
    _currentPhotos = widget.poster.photos.toList();
    _currentPhotos.sortByIdDescending();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentSize = MediaQuery.of(context).size;
    final lightBorderColor = ThemeColors.textLight;
    var imageRowHeight = 130.0;
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
              Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                height: imageRowHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: _currentPhotos.isEmpty
                          ? _getDummyAsset()
                          : CarouselSlider.builder(
                              controller: _imageSliderController,
                              itemCount: _currentPhotos.length,
                              itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                height: imageRowHeight,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                                ),
                                child: Container(
                                  width: currentSize.width,
                                  height: imageRowHeight,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                                  ),
                                  child: _getPosterPreview(itemIndex),
                                ),
                              ),
                              options: CarouselOptions(
                                onPageChanged: (index, reason) {
                                  setState(() => _currentImageIndex = index);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    _currentPhotos.isEmpty
                        ? SizedBox.shrink()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<int>.generate(_currentPhotos.length, (i) => i).asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () => _imageSliderController.animateToPage(entry.key),
                                child: Container(
                                  width: 12.0,
                                  height: 12.0,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withAlpha(_currentImageIndex == entry.key ? 225 : 100),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    Positioned(
                      right: 6,
                      child: PopupMenuButton<PhotoEditAction>(
                        color: ThemeColors.background,
                        onSelected: (PhotoEditAction result) {
                          switch (result) {
                            case PhotoEditAction.acquireNewPhoto:
                              _acquireNewPhoto();
                            case PhotoEditAction.usePhotoFromGallery:
                              _pickImageFromDevice();
                          }
                        },
                        offset: Offset(0, 41),
                        child: Container(
                          width: 41,
                          height: 41,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ThemeColors.secondary.withAlpha(100), width: 2),
                          ),
                          child: Center(child: Icon(Icons.photo_camera_outlined, size: 30.0)),
                        ),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<PhotoEditAction>>[
                          PopupMenuItem<PhotoEditAction>(
                            value: PhotoEditAction.acquireNewPhoto,
                            child: Row(
                              children: [
                                Icon(Icons.add_a_photo_outlined),
                                SizedBox(width: 12),
                                Text(t.campaigns.poster.photoEditActions.acquireNewPhoto),
                              ],
                            ),
                          ),
                          PopupMenuItem<PhotoEditAction>(
                            value: PhotoEditAction.usePhotoFromGallery,
                            child: Row(
                              children: [
                                Icon(Icons.image_outlined),
                                SizedBox(width: 12),
                                Text(t.campaigns.poster.photoEditActions.uploadFile),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [Text(t.campaigns.poster.editPoster, style: theme.textTheme.titleLarge)]),
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
                child: Column(children: [...PosterStatusHelper.getPosterStatusList.map(_getRadioItem)]),
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
                        t.campaigns.poster.deletePoster.hint,
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

  Widget _getDummyAsset() => Image.asset(CampaignConstants.dummyImageAssetName);

  Widget _getPosterPreview(int itemIndex) {
    var photo = _currentPhotos[itemIndex];
    return FutureBuilder(
      future: Future.delayed(Duration.zero, () => (imageUrl: photo.imageUrl)),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return _getDummyAsset();
        }

        return GestureDetector(
          onTap: _showPictureFullView,
          child: snapshot.data!.imageUrl.isNetworkImageUrl()
              ? FadeInImage.assetNetwork(
                  placeholder: CampaignConstants.dummyImageAssetName,
                  image: snapshot.data!.imageUrl,
                  fit: BoxFit.cover,
                )
              : Image.file(File(snapshot.data!.imageUrl), fit: BoxFit.cover),
        );
      },
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

    reduceImage(PosterPhotoModel p) async {
      var file = File(p.imageUrl);
      final reducedImage = await Future.delayed(
        Duration(milliseconds: 150),
        () => MediaHelper.resizeAndReduceImageFile(file),
      );

      var fileLocation = await MediaHelper.storeImage(reducedImage!);
      return p.copyWith(imageUrl: fileLocation, thumbnailUrl: fileLocation);
    }

    var newPhotosReduced = <PosterPhotoModel>[];
    for (var p in _newPhotos) {
      var newPhoto = await reduceImage(p);
      newPhotosReduced.add(newPhoto);
    }

    final updateModel = widget.poster.asPosterUpdate().copyWith(
      address: getAddress(),
      status: _selectedPosterStatus,
      comment: commentTextController.text,
      location: widget.poster.location,
      deletedPhotoIds: _deletedPhotoIds,
      newPhotos: newPhotosReduced,
    );
    await widget.onSave(updateModel);

    _closeDialog(ModalEditResult.save);
  }

  Future<bool> _acquireNewPhoto() async {
    final photo = await MediaHelper.acquirePhoto(context);

    if (photo == null) {
      return false;
    }
    _addNewPhoto(photo);
    return true;
  }

  void _addNewPhoto(File photo) {
    var newPhoto = PosterPhotoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: photo.absolute.path,
      thumbnailUrl: photo.absolute.path,
      createdAt: DateTime.now(),
    );
    _newPhotos.add(newPhoto);
    setState(() {
      _currentPhotos.insert(0, newPhoto);
      _imageSliderController.jumpToPage(0);
      _currentImageIndex = 0;
    });
  }

  void _showPictureFullView() async {
    ImageProvider getImageProvider(PosterPhotoModel photo) {
      ImageProvider imageProvider;
      if (photo.imageUrl.isNetworkImageUrl()) {
        imageProvider = NetworkImage(photo.imageUrl);
      } else {
        imageProvider = FileImage(File(photo.imageUrl));
      }
      return imageProvider;
    }

    getAllImages() => _currentPhotos;

    MediaHelper.showPictureGalleryInFullView(
      context: context,
      getImageProvider: getImageProvider,
      getAllImages: getAllImages,
      currentImageIndex: _currentImageIndex,
      removeImage: _removeImage,
      downloadImage: _downloadImage,
      replaceImageWithCamera: _replaceImageWithCamera,
      replaceImageWithDevice: _replaceImageWithDevice,
    );

    setState(() {
      _currentImageIndex = min(_currentImageIndex, _currentPhotos.length - 1);
      _imageSliderController.jumpToPage(_currentImageIndex);
    });
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

  Future<bool> _pickImageFromDevice() async {
    final photo = await MediaHelper.pickImageFromDevice(context);

    if (photo == null) {
      return false;
    }
    _addNewPhoto(photo);
    return true;
  }

  void _removeImage(int itemIndex) {
    setState(() {
      var currentPhoto = _currentPhotos[itemIndex];
      _deletedPhotoIds.add(currentPhoto.id);
      _currentPhotos.removeAt(itemIndex);
    });
  }

  PosterStatus _selectedPosterStatus = PosterStatus.ok;

  Widget _getRadioItem((PosterStatus, String) item) {
    var theme = Theme.of(context);
    return RadioListTile<PosterStatus>(
      value: item.$1,
      groupValue: _selectedPosterStatus,
      onChanged: (value) => setState(() {
        _selectedPosterStatus = value!;
      }),
      fillColor: WidgetStatePropertyAll(ThemeColors.primary),
      title: Text(item.$2, style: theme.textTheme.bodyMedium),
      visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity, horizontal: VisualDensity.minimumDensity),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _downloadImage(int imageIndex) {
    var currentPhoto = _currentPhotos[imageIndex];
    MediaHelper.storeImageOnDevice(currentPhoto);
  }

  Future<bool> _replaceImageWithCamera(int imageIndex) async {
    return await _replaceImage(imageIndex, _acquireNewPhoto);
  }

  Future<bool> _replaceImageWithDevice(int imageIndex) async {
    return await _replaceImage(imageIndex, _pickImageFromDevice);
  }

  Future<bool> _replaceImage(int imageIndex, Future<bool> Function() getNewImage) async {
    var currentPhoto = _currentPhotos[imageIndex];
    if (await getNewImage()) {
      var newIndex = _currentPhotos.indexOf(currentPhoto);
      _removeImage(newIndex);
      return true;
    }
    return false;
  }
}
