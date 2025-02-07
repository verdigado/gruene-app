import 'package:flutter/material.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileBaseData extends StatelessWidget {
  final Profile profile;

  const ProfileBaseData({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileCard(
          child: Column(
            children: [
              _buildValueRow(context, t.profiles.baseData.firstName, profile.firstName),
              Divider(),
              _buildValueRow(context, t.profiles.baseData.lastName, profile.lastName),
              Divider(),
              _buildValueRow(context, t.profiles.baseData.email, profile.email),
              if (profile.phoneNumbers.isNotEmpty) ...[
                Divider(),
                _buildValueRow(context, t.profiles.baseData.phoneNumber, profile.phoneNumbers.first.number),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          value,
          style: theme.textTheme.bodyLarge?.apply(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
