import 'dart:io';
import 'dart:math';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_photo_model.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/extensions.dart';
import 'package:gruene_app/features/campaigns/domain/actions/shared/photo_edit_controller.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:gruene_app/i18n/translations.g.dart';

enum PhotoEditAction { acquireNewPhoto, usePhotoFromGallery }

/// The photos of a pin, newest first, in a carousel with page dots on the photos; tapping a photo opens all of them
/// full screen. Without photos it shows nothing.
class PhotoCarousel extends StatefulWidget {
  final List<PosterPhotoModel> photos;
  final double height;

  const PhotoCarousel({super.key, required this.photos, this.height = 160});

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final _sliderController = CarouselSliderController();
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          _PhotoSlider(
            photos: photos,
            controller: _sliderController,
            height: widget.height,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            onTap: _showFullView,
          ),
          if (photos.length > 1)
            _PageDots(
              count: photos.length,
              currentIndex: min(_currentIndex, photos.length - 1),
              onTap: _sliderController.animateToPage,
            ),
        ],
      ),
    );
  }

  void _showFullView(int index) => MediaHelper.showPictureGalleryInFullView(
    context: context,
    getImageProvider: _imageProvider,
    getAllImages: () => widget.photos,
    currentImageIndex: index,
  );
}

/// Edits the photos of a pin in its form: a carousel of the photos (newest first, the placeholder image while there are
/// none) with the page dots on the photos and a camera button at the top right to take or pick a photo. Tapping a photo
/// opens all of them full screen, where a photo can be downloaded, replaced or deleted.
class PhotoCarouselEditor extends StatefulWidget {
  final PhotoEditController controller;

  /// The height of the photo row, including a padding of 6 above and below.
  final double height;

  /// Asked before a photo is deleted, in words that fit the pin type.
  final String deleteConfirmationText;

  /// Shown with the newest photo in the full view, e.g. "Aktuelles Bild" for posters; none if null.
  final String? currentPhotoLabel;

  /// The start of the file name of a downloaded photo.
  final String downloadFileNamePrefix;

  /// Shown while there are no photos, filling the photo row.
  final String placeholderAssetName;

  const PhotoCarouselEditor({
    super.key,
    required this.controller,
    this.height = 130,
    required this.deleteConfirmationText,
    this.currentPhotoLabel,
    this.downloadFileNamePrefix = 'poster',
    this.placeholderAssetName = CampaignConstants.dummyImageAssetName,
  });

  @override
  State<PhotoCarouselEditor> createState() => _PhotoCarouselEditorState();
}

class _PhotoCarouselEditorState extends State<PhotoCarouselEditor> {
  final _sliderController = CarouselSliderController();
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPhotosChanged);
  }

  @override
  void didUpdateWidget(PhotoCarouselEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onPhotosChanged);
      widget.controller.addListener(_onPhotosChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPhotosChanged);
    super.dispose();
  }

  void _onPhotosChanged() {
    if (!mounted) return;
    setState(() => _currentIndex = min(_currentIndex, max(0, widget.controller.photos.length - 1)));
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.controller.photos;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          photos.isEmpty
              ? Image.asset(widget.placeholderAssetName, fit: BoxFit.cover)
              : _PhotoSlider(
                  photos: photos,
                  controller: _sliderController,
                  height: widget.height - 12,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  onTap: _showFullView,
                ),
          if (photos.length > 1)
            _PageDots(count: photos.length, currentIndex: _currentIndex, onTap: _sliderController.animateToPage),
          Positioned(top: 6, right: 6, child: _cameraButton()),
        ],
      ),
    );
  }

  Widget _cameraButton() {
    return PopupMenuButton<PhotoEditAction>(
      color: ThemeColors.background,
      tooltip: t.campaigns.photo.actions.acquireNewPhoto,
      onSelected: (PhotoEditAction result) {
        switch (result) {
          case PhotoEditAction.acquireNewPhoto:
            _addPhoto(MediaHelper.acquirePhoto);
          case PhotoEditAction.usePhotoFromGallery:
            _addPhoto(MediaHelper.pickImageFromDevice);
        }
      },
      offset: const Offset(0, 41),
      // on top of the photos, so it has a background of its own
      child: Container(
        width: 41,
        height: 41,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeColors.background.withAlpha(230),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: const Center(child: Icon(Icons.photo_camera_outlined, size: 26.0, color: ThemeColors.primary)),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<PhotoEditAction>>[
        PopupMenuItem<PhotoEditAction>(
          value: PhotoEditAction.acquireNewPhoto,
          child: Row(
            children: [
              const Icon(Icons.add_a_photo_outlined),
              const SizedBox(width: 12),
              Flexible(child: Text(t.campaigns.photo.actions.acquireNewPhoto)),
            ],
          ),
        ),
        PopupMenuItem<PhotoEditAction>(
          value: PhotoEditAction.usePhotoFromGallery,
          child: Row(
            children: [
              const Icon(Icons.image_outlined),
              const SizedBox(width: 12),
              Flexible(child: Text(t.campaigns.photo.actions.uploadFile)),
            ],
          ),
        ),
      ],
    );
  }

  /// Takes or picks a photo and shows it first; false if none was taken.
  Future<bool> _addPhoto(Future<File?> Function(BuildContext) getPhoto) async {
    final photo = await getPhoto(context);
    if (photo == null || !mounted) return false;

    final hadPhotos = widget.controller.photos.isNotEmpty;
    widget.controller.add(photo);
    // the carousel exists only while there are photos
    if (hadPhotos) _sliderController.jumpToPage(0);
    setState(() => _currentIndex = 0);
    return true;
  }

  Future<bool> _replacePhoto(int index, Future<File?> Function(BuildContext) getPhoto) async {
    final replacedPhoto = widget.controller.photos[index];
    if (!await _addPhoto(getPhoto)) return false;
    widget.controller.remove(replacedPhoto);
    return true;
  }

  Future<void> _showFullView(int index) async {
    final controller = widget.controller;
    await MediaHelper.showPictureGalleryInFullView(
      context: context,
      getImageProvider: _imageProvider,
      getAllImages: () => controller.photos,
      currentImageIndex: index,
      removeImage: controller.removeAt,
      downloadImage: (index) =>
          MediaHelper.storeImageOnDevice(controller.photos[index], fileNamePrefix: widget.downloadFileNamePrefix),
      replaceImageWithCamera: (index) => _replacePhoto(index, MediaHelper.acquirePhoto),
      replaceImageWithDevice: (index) => _replacePhoto(index, MediaHelper.pickImageFromDevice),
      deleteConfirmationText: widget.deleteConfirmationText,
      currentPictureLabel: widget.currentPhotoLabel,
    );
    if (!mounted || controller.photos.isEmpty) return;
    _sliderController.jumpToPage(_currentIndex);
  }
}

ImageProvider _imageProvider(PosterPhotoModel photo) =>
    photo.imageUrl.isNetworkImageUrl() ? NetworkImage(photo.imageUrl) : FileImage(File(photo.imageUrl));

class _PhotoSlider extends StatelessWidget {
  final List<PosterPhotoModel> photos;
  final CarouselSliderController controller;
  final double height;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTap;

  const _PhotoSlider({
    required this.photos,
    required this.controller,
    required this.height,
    required this.onPageChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero);
    return CarouselSlider.builder(
      controller: controller,
      itemCount: photos.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: GestureDetector(
            onTap: () => onTap(itemIndex),
            child: SizedBox(width: double.infinity, height: height, child: _photo(photos[itemIndex])),
          ),
        ),
      ),
      options: CarouselOptions(height: height, onPageChanged: (index, reason) => onPageChanged(index)),
    );
  }

  Widget _photo(PosterPhotoModel photo) {
    Widget placeholder(BuildContext context, Object error, StackTrace? stackTrace) =>
        Image.asset(CampaignConstants.dummyImageAssetName);

    return photo.imageUrl.isNetworkImageUrl()
        ? FadeInImage.assetNetwork(
            placeholder: CampaignConstants.dummyImageAssetName,
            image: photo.imageUrl,
            fit: BoxFit.cover,
            imageErrorBuilder: placeholder,
          )
        : Image.file(File(photo.imageUrl), fit: BoxFit.cover, errorBuilder: placeholder);
  }
}

/// The page dots at the bottom center, on top of the photos; light with a shadow, so that they show on any photo.
class _PageDots extends StatelessWidget {
  final int count;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PageDots({required this.count, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                width: 10.0,
                height: 10.0,
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(currentIndex == index ? 255 : 140),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 2)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
