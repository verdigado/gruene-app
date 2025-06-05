import 'package:flutter/material.dart';
import 'package:gruene_app/features/profiles/domain/profiles_api_service.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

class ProfileImageDeleter extends StatelessWidget {
  final Profile profile;
  final ValueChanged<Profile> onProfileUpdated;
  final ValueChanged<bool> onProcessing;

  const ProfileImageDeleter({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onProcessing,
  });

  Future<void> _deleteProfileImage(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(t.profiles.profileImage.confirmDelete.title, style: theme.textTheme.titleLarge),
          content: Text(t.profiles.profileImage.confirmDelete.text),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 8),
          actionsPadding: EdgeInsets.all(8),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.common.actions.cancel)),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t.common.actions.delete)),
          ],
        );
      },
    );

    if (confirmed != true) return;

    onProcessing(true);

    try {
      final response = await deleteProfileImage(profileId: profile.id);
      onProfileUpdated(response);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(error is ClientException ? t.error.offlineError : t.profiles.profileImage.deleteError)),
      );
    }

    onProcessing(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () => _deleteProfileImage(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        t.profiles.profileImage.delete,
        style: theme.textTheme.bodyMedium!.apply(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
