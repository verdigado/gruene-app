import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteProfileImageDialog(),
    );

    if (confirmed != true) return;

    onProcessing(true);

    try {
      final response = await deleteProfileImage(profileId: profile.id);
      onProfileUpdated(response);
    } catch (error) {
      _showError(context, error is ClientException ? t.error.offlineError : t.profiles.profileImage.deleteError);
    }

    onProcessing(false);
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

class DeleteProfileImageDialog extends StatelessWidget {
  const DeleteProfileImageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(t.profiles.profileImage.confirmDelete.title),
      titleTextStyle: theme.textTheme.titleMedium?.apply(color: ThemeColors.textDark),
      content: Text(t.profiles.profileImage.confirmDelete.text),
      contentTextStyle: theme.textTheme.bodyMedium?.apply(color: ThemeColors.textDark),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            t.common.actions.cancel,
            style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textCancel),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            t.common.actions.delete,
            style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textWarning),
          ),
        ),
      ],
    );
  }
}
