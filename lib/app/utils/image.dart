import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<MultipartFile> multipartImage(File image, String formField) async {
  final String fileName = image.path.split('/').last;
  return MultipartFile.fromBytes(
    formField,
    await image.readAsBytes(),
    filename: fileName,
    contentType: MediaType('image', 'jpeg'),
  );
}

Future<File?> pickImage(BuildContext context, [CropAspectRatio? aspectRatio]) async {
  final ImagePicker picker = ImagePicker();
  final theme = Theme.of(context);

  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return null;

  final String? filePath = aspectRatio != null
      ? (await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: aspectRatio,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: t.common.actions.crop,
              toolbarColor: theme.colorScheme.primary,
              activeControlsWidgetColor: theme.colorScheme.secondary,
              toolbarWidgetColor: theme.colorScheme.surface,
              lockAspectRatio: true,
            ),
            IOSUiSettings(title: t.common.actions.crop, aspectRatioLockEnabled: true),
          ],
        ))?.path
      : pickedFile.path;

  if (filePath == null) return null;

  return File(filePath);
}
