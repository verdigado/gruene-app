import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_photo_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:photo_view/photo_view_gallery.dart';

enum PhotoGalleryAction { downloadPhoto, deletePhoto, replacePhoto, replacePhotoWithCamera, replacePhotoWithImage }

enum PictureViewConfirmationDialogOptions { replace, delete }

typedef GetImageProviderCallback = ImageProvider<Object> Function(PosterPhotoModel photo);
typedef GetAllImagesCallback = List<PosterPhotoModel> Function();
typedef RemoveImageCallback = void Function(int imageIndex);
typedef DownloadImageCallback = void Function(int imageIndex);
typedef ReplaceImageWithCameraCallback = Future<bool> Function(int imageIndex);
typedef ReplaceImageWithDeviceCallback = Future<bool> Function(int imageIndex);

class PictureGalleryView extends StatefulWidget {
  final GetImageProviderCallback getImageProvider;
  final GetAllImagesCallback getAllImages;

  final int currentImageIndex;
  final RemoveImageCallback removeImage;
  final DownloadImageCallback downloadImage;
  final ReplaceImageWithCameraCallback replaceImageWithCamera;
  final ReplaceImageWithDeviceCallback replaceImageWithDevice;

  const PictureGalleryView({
    super.key,
    required this.getImageProvider,
    required this.getAllImages,
    required this.currentImageIndex,
    required this.removeImage,
    required this.downloadImage,
    required this.replaceImageWithCamera,
    required this.replaceImageWithDevice,
  });

  @override
  State<PictureGalleryView> createState() => _PictureGalleryViewState();
}

class _PictureGalleryViewState extends State<PictureGalleryView> {
  late PageController _imageSliderController;
  var _currentImageIndex = 0;

  @override
  void initState() {
    _imageSliderController = PageController(initialPage: widget.currentImageIndex);
    _currentImageIndex = widget.currentImageIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var allImages = widget.getAllImages();

    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoViewGallery.builder(
              pageController: _imageSliderController,
              itemCount: allImages.length,
              backgroundDecoration: BoxDecoration(color: ThemeColors.text.withAlpha(120)),
              builder: (context, index) =>
                  PhotoViewGalleryPageOptions(imageProvider: widget.getImageProvider(allImages[index])),
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<int>.generate(allImages.length, (i) => i).asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _imageSliderController.jumpToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key ? ThemeColors.secondary : Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 14,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                getImageText(allImages),
                style: theme.textTheme.labelSmall!.copyWith(color: ThemeColors.background),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 14,
            child: Align(alignment: Alignment.bottomRight, child: _getGalleryPopUpMenu()),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: GestureDetector(
              onTap: _closeWindow,
              child: Icon(Icons.close_outlined, color: theme.colorScheme.surface, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<PhotoGalleryAction> _getGalleryPopUpMenu() {
    return PopupMenuButton<PhotoGalleryAction>(
      color: ThemeColors.background,
      onSelected: _doGalleryAction,
      child: Icon(Icons.more_vert_outlined, color: ThemeColors.background),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<PhotoGalleryAction>>[
        PopupMenuItem<PhotoGalleryAction>(
          value: PhotoGalleryAction.downloadPhoto,
          child: Row(
            children: [
              Icon(Icons.file_download_outlined),
              SizedBox(width: 12),
              Text(t.campaigns.poster.photoEditActions.downloadPicture),
            ],
          ),
        ),
        PopupMenuItem<PhotoGalleryAction>(
          value: PhotoGalleryAction.deletePhoto,
          child: Row(
            children: [
              Icon(Icons.delete_outlined),
              SizedBox(width: 12),
              Text(t.campaigns.poster.photoEditActions.deletePhoto),
            ],
          ),
        ),
        PopupMenuItem<PhotoGalleryAction>(
          value: PhotoGalleryAction.replacePhoto,
          child: PopupMenuButton(
            color: ThemeColors.background,
            onOpened: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt_outlined),
                    SizedBox(width: 12),
                    Text(t.campaigns.poster.photoEditActions.replacePhoto),
                  ],
                ),
                Icon(Icons.arrow_right_outlined),
              ],
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PhotoGalleryAction>>[
              PopupMenuItem<PhotoGalleryAction>(
                value: PhotoGalleryAction.replacePhotoWithCamera,
                child: Row(
                  children: [
                    Icon(Icons.add_a_photo_outlined),
                    SizedBox(width: 12),
                    Text(t.campaigns.poster.photoEditActions.acquireNewPhoto),
                  ],
                ),
                onTap: () => _doGalleryAction(PhotoGalleryAction.replacePhotoWithCamera),
              ),
              PopupMenuItem<PhotoGalleryAction>(
                value: PhotoGalleryAction.replacePhotoWithImage,
                child: Row(
                  children: [
                    Icon(Icons.image_outlined),
                    SizedBox(width: 12),
                    Text(t.campaigns.poster.photoEditActions.uploadFile),
                  ],
                ),
                onTap: () => _doGalleryAction(PhotoGalleryAction.replacePhotoWithImage),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _doGalleryAction(PhotoGalleryAction result) async {
    setCurrentImageIndex(int index) {
      _currentImageIndex = index;
      _imageSliderController.jumpToPage(index);
    }

    switch (result) {
      case PhotoGalleryAction.downloadPhoto:
        widget.downloadImage(_currentImageIndex);
      case PhotoGalleryAction.deletePhoto:
        if (await _showConfirmationDialog(context, PictureViewConfirmationDialogOptions.delete)) {
          widget.removeImage(_currentImageIndex);
          var currentImages = widget.getAllImages();
          if (currentImages.isEmpty) {
            _closeWindow();
            return;
          }
          setCurrentImageIndex(min(_currentImageIndex, widget.getAllImages().length - 1));
        }
      case PhotoGalleryAction.replacePhoto:
        throw UnimplementedError();
      case PhotoGalleryAction.replacePhotoWithCamera:
        if (await _showConfirmationDialog(context, PictureViewConfirmationDialogOptions.replace)) {
          var result = await widget.replaceImageWithCamera(_currentImageIndex);
          if (result) setCurrentImageIndex(0);
        }
      case PhotoGalleryAction.replacePhotoWithImage:
        if (await _showConfirmationDialog(context, PictureViewConfirmationDialogOptions.replace)) {
          var result = await widget.replaceImageWithDevice(_currentImageIndex);
          if (result) setCurrentImageIndex(0);
        }
    }
    setState(() {});
  }

  void _closeWindow() {
    Navigator.maybePop(context);
  }

  Future<bool> _showConfirmationDialog(BuildContext context, PictureViewConfirmationDialogOptions options) async {
    var optionSet = switch (options) {
      PictureViewConfirmationDialogOptions.replace => (
        title: t.campaigns.poster.photoEditActions.confirmation_dialog.title_replace,
        text: t.campaigns.poster.photoEditActions.confirmation_dialog.text_replace,
        actionText: t.campaigns.poster.photoEditActions.replacePhoto,
        icon: Icons.camera_alt_outlined,
      ),
      PictureViewConfirmationDialogOptions.delete => (
        title: t.campaigns.poster.photoEditActions.confirmation_dialog.title_delete,
        text: t.campaigns.poster.photoEditActions.confirmation_dialog.text_delete,
        actionText: t.campaigns.poster.photoEditActions.deletePhoto,
        icon: Icons.delete_outlined,
      ),
    };

    final theme = Theme.of(context);
    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.backgroundSecondary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(optionSet.title, style: theme.textTheme.titleMedium?.apply(color: ThemeColors.textDark))],
          ),
          content: Text(
            optionSet.text,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDark, fontSizeDelta: 1),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.maybePop(context, false),
              child: Text(
                t.common.actions.cancel,
                style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.textDark),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.maybePop(context, true),
              label: Text(optionSet.actionText, style: theme.textTheme.bodyMedium?.apply(color: ThemeColors.textDark)),
              icon: Icon(optionSet.icon),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  String getImageText(List<PosterPhotoModel> allImages) {
    var title = '';
    if (_currentImageIndex == 0) title += t.campaigns.poster.pictureView.currentPicture_label;
    return title;
  }
}
