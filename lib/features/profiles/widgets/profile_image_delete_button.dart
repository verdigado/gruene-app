import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/api/profile_api_service.dart';
import 'package:gruene_app/app/widgets/alert.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart';

class ProfileImageDeleteButton extends StatelessWidget {
  final void Function(Profile profile) update;
  final void Function(bool processing) setLoading;
  final Profile profile;

  const ProfileImageDeleteButton({super.key, required this.profile, required this.update, required this.setLoading});

  Future<void> _deleteProfileImage(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmationDialog(
      context,
      title: t.profiles.profileImage.confirmDelete.title,
      label: t.common.actions.delete,
      content: Text(t.profiles.profileImage.confirmDelete.text),
    );

    if (confirmed != true) return;

    setLoading(true);

    try {
      final response = await GetIt.I<ProfileApiService>().deleteProfileImage(profileId: profile.id);
      update(response);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(error is ClientException ? t.error.offline : t.profiles.profileImage.deleteError)),
      );
    }

    setLoading(false);
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
        style: theme.textTheme.bodyMedium!.apply(decoration: TextDecoration.underline),
      ),
    );
  }
}
