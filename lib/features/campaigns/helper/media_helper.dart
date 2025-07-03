import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/app_settings.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/features/campaigns/helper/file_cache_manager.dart';
import 'package:gruene_app/features/campaigns/helper/picture_gallery_view.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_photo_model.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as image_lib;
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class MediaHelper {
  static const int maxUploadDimension = 1200;

  static Future<File?> acquirePhoto(BuildContext context) async {
    await showImageConsent(context);
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      return File(pickedImage.path);
    }

    return null;
  }

  static Future<File?> pickImageFromDevice(BuildContext context) async {
    await showImageConsent(context);
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    return null;
  }

  static Future<void> showImageConsent(BuildContext context) async {
    var appSettings = GetIt.I<AppSettings>();
    final theme = Theme.of(context);
    if (appSettings.campaign.imageConsentConfirmed) return;
    await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.alertBackground,
          content: Text(
            t.campaigns.poster.photoConsentMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(color: theme.colorScheme.surface, fontSizeDelta: 1),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: Text(
                t.common.actions.consent,
                style: theme.textTheme.labelLarge?.apply(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        );
      },
    );
    appSettings.campaign.imageConsentConfirmed = true;
  }

  static Future<Uint8List?> resizeAndReduceImageFile(File? photo) async {
    if (photo == null) return null;
    final fileContent = await photo.readAsBytes();
    return await resizeAndReduceImage(fileContent, ImageType.jpeg);
  }

  static Future<Uint8List> resizeAndReduceImage(Uint8List originalImage, ImageType outputType) async {
    Uint8List? resizedImg;

    final compressAction = Future.delayed(Duration.zero, () async {
      image_lib.Image? img = image_lib.decodeImage(originalImage);
      image_lib.Image resized;
      if (img!.height > maxUploadDimension || img.width > maxUploadDimension) {
        int desiredWidth, desiredHeight;
        if (img.width > img.height) {
          desiredWidth = maxUploadDimension;
          desiredHeight = (img.height / img.width * maxUploadDimension).round();
        } else {
          desiredHeight = maxUploadDimension;
          desiredWidth = (img.width / img.height * maxUploadDimension).round();
        }

        resized = image_lib.copyResize(img, width: desiredWidth, height: desiredHeight, maintainAspect: true);
      } else {
        resized = img;
      }

      resizedImg = switch (outputType) {
        ImageType.jpeg => Uint8List.fromList(image_lib.encodeJpg(resized, quality: 60)),
        ImageType.png => Uint8List.fromList(image_lib.encodePng(resized)),
      };
    });

    await compressAction;
    return resizedImg!;
  }

  static void showPictureInFullView(BuildContext context, ImageProvider imageProvider) async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: Navigator.of(context).context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              child: PhotoView(
                backgroundDecoration: BoxDecoration(color: ThemeColors.text.withAlpha(120)),
                imageProvider: imageProvider,
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Icon(Icons.close, color: theme.colorScheme.surface, size: 30),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showPictureGalleryInFullView({
    required BuildContext context,
    required GetImageProviderCallback getImageProvider,
    required GetAllImagesCallback getAllImages,
    required int currentImageIndex,
    required RemoveImageCallback removeImage,
    required DownloadImageCallback downloadImage,
    required ReplaceImageWithCameraCallback replaceImageWithCamera,
    required ReplaceImageWithDeviceCallback replaceImageWithDevice,
  }) async {
    await showDialog<void>(
      context: Navigator.of(context).context,
      barrierDismissible: true,
      builder: (BuildContext context) => PictureGalleryView(
        getImageProvider: getImageProvider,
        getAllImages: getAllImages,
        currentImageIndex: currentImageIndex,
        removeImage: removeImage,
        downloadImage: downloadImage,
        replaceImageWithCamera: replaceImageWithCamera,
        replaceImageWithDevice: replaceImageWithDevice,
      ),
    );
  }

  static Future<String> storeImage(Uint8List imageData) async {
    var fileLocation = await GetIt.I<FileManager>().storeFile(
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
      imageData,
    );
    var exists = await File(fileLocation).exists();
    assert(exists, 'file does not exist');
    return fileLocation;
  }

  static void removeAllFiles() {
    GetIt.I<FileManager>().clearAllFiles();
  }

  static void storeImageOnDevice(PosterPhotoModel currentPhoto) async {
    var imageUrl = currentPhoto.imageUrl;

    var now = DateTime.now();
    var fileName = 'poster_${now.getAsTimeStamp()}.jpg';

    if (imageUrl.isNetworkImageUrl()) {
      final Response response = await get(Uri.parse(imageUrl));

      // Save to filesystem
      final params = SaveFileDialogParams(data: response.bodyBytes, fileName: fileName);
      await FlutterFileDialog.saveFile(params: params);
    } else {
      final params = SaveFileDialogParams(sourceFilePath: imageUrl, fileName: fileName);
      await FlutterFileDialog.saveFile(params: params);
    }
  }
}
