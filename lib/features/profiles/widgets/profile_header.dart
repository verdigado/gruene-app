import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/horizontal_divider.dart';
import 'package:gruene_app/features/profiles/widgets/profile_image_delete_button.dart';
import 'package:gruene_app/features/profiles/widgets/profile_image_edit_button.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileHeader extends StatefulWidget {
  final Profile profile;
  final void Function(Profile profile) update;

  const ProfileHeader({super.key, required this.profile, required this.update});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool loading = false;

  void _setLoading(bool isLoading) => setState(() => loading = isLoading);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.profile.image?.thumbnail.url;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
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
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null ? Icon(Icons.person, size: 90, color: theme.colorScheme.surface) : null,
              ),
              if (loading)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        Text('${widget.profile.firstName} ${widget.profile.lastName}', style: theme.textTheme.titleLarge),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileImageEditButton(profile: widget.profile, update: widget.update, setLoading: _setLoading),
            if (widget.profile.image != null)
              ProfileImageDeleteButton(profile: widget.profile, update: widget.update, setLoading: _setLoading),
          ].withDividers(HorizontalDivider(color: theme.disabledColor)),
        ),
      ],
    );
  }
}
