import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/image.dart';
import 'package:gruene_app/app/utils/loading_overlay.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileImageEditButton extends StatelessWidget {
  final void Function(Profile profile) update;
  final void Function(bool processing) setLoading;
  final Profile profile;

  const ProfileImageEditButton({super.key, required this.profile, required this.update, required this.setLoading});

  Future<void> _editProfileImage(BuildContext context) async {
    final imageFile = await pickImage(context, CropAspectRatio(ratioX: 1, ratioY: 1));
    if (imageFile == null) return;
    final image = await multipartImage(imageFile, 'profileImage');
    final newProfile = await updateProfileImage(profileId: profile.id, profileImage: image);
    update(newProfile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () => tryAndNotify(
        function: () async => _editProfileImage(context),
        context: context,
        successMessage: t.profiles.profileImage.updated,
        setLoading: setLoading,
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        t.profiles.profileImage.edit,
        style: theme.textTheme.bodyMedium!.apply(decoration: TextDecoration.underline),
      ),
    );
  }
}
