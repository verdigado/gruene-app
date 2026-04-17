import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/utils/utils.dart';
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
              _buildValueRow(context, t.profiles.baseData.lastName, profile.lastName),
              _buildValueRow(context, t.profiles.baseData.email, profile.email),
              if (profile.phoneNumbers.isNotEmpty) ...[
                _buildValueRow(context, t.profiles.baseData.phoneNumber, profile.phoneNumbers.first.number),
              ],
              _buildValueRow(context, t.profiles.personalId, profile.personalId),
            ].withDividers(Divider(indent: 16, endIndent: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(value, style: theme.textTheme.bodyLarge?.apply(color: theme.colorScheme.primary)),
      ),
      onTap: () => Clipboard.setData(ClipboardData(text: value)),
    );
  }
}
