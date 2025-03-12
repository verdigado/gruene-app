import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageUploader extends StatelessWidget {
  final Profile profile;
  final ValueChanged<Profile> onProfileUpdated;
  final ValueChanged<bool> onProcessing;

  const ProfileImageUploader({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onProcessing,
  });

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: t.profiles.profileImage.crop,
          toolbarColor: theme.colorScheme.primary,
          activeControlsWidgetColor: theme.colorScheme.secondary,
          toolbarWidgetColor: theme.colorScheme.surface,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: t.profiles.profileImage.crop,
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile == null) return;

    final File imageFile = File(croppedFile.path);
    final String fileName = imageFile.path.split('/').last;
    final MultipartFile multipartFile = MultipartFile.fromBytes(
      'profileImage',
      await imageFile.readAsBytes(),
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    );

    onProcessing(true);

    try {
      final response = await updateProfileImage(
        profileId: profile.id,
        profileImage: multipartFile,
      );

      onProfileUpdated(response);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(error is ClientException ? t.error.offlineError : t.profiles.profileImage.updateError)),
      );
    }

    onProcessing(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () => _pickAndUploadImage(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        t.profiles.profileImage.update,
        style: theme.textTheme.bodyMedium!.apply(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
