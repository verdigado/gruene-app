import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeader extends StatefulWidget {
  final Profile profile;
  final ValueChanged<Profile> onProfileUpdated;

  const ProfileHeader({super.key, required this.profile, required this.onProfileUpdated});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final BuildContext context = this.context;
    final theme = Theme.of(context);

    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: t.profiles.profileImage.crop,
          toolbarColor: theme.primaryColor,
          activeControlsWidgetColor: theme.colorScheme.secondary,
          toolbarWidgetColor: Colors.white,
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

    setState(() => _isUploading = true);

    try {
      final response = await updateProfileImage(
        profileId: widget.profile.id,
        profileImage: multipartFile,
      );

      widget.onProfileUpdated(response);
    } catch (e) {
      _showError('${t.profiles.profileImage.error} $e');
    }

    setState(() => _isUploading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: ThemeColors.textDisabled,
                backgroundImage: widget.profile.image?.thumbnail.url != null
                    ? NetworkImage(widget.profile.image!.thumbnail.url)
                    : null,
                child: widget.profile.image?.thumbnail.url == null
                    ? Icon(Icons.person, size: 90, color: theme.colorScheme.surface)
                    : null,
              ),
              if (_isUploading)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        SizedBox(height: 6),
        Text(
          '${widget.profile.firstName} ${widget.profile.lastName}',
          style: theme.textTheme.titleLarge,
        ),
        TextButton(
          onPressed: _isUploading ? null : _pickAndUploadImage,
          child: Text(
            t.profiles.profileImage.update,
            style: theme.textTheme.bodyMedium!.apply(
              color: ThemeColors.text,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
