import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/profiles.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/horizontal_divider.dart';
import 'package:gruene_app/features/profiles/widgets/profile_image_delete_button.dart';
import 'package:gruene_app/features/profiles/widgets/profile_image_edit_button.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileImage extends StatelessWidget {
  final PublicProfile profile;
  final double? size;

  const ProfileImage({super.key, required this.profile, this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = profile.image?.thumbnail.url;
    final size = this.size;

    return CircleAvatar(
      radius: size != null ? size / 2 : null,
      backgroundColor: ThemeColors.textDisabled,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null ? Icon(Icons.person, size: size, color: theme.colorScheme.surface) : null,
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final PublicProfile profile;
  final bool imageLoading;
  final List<Widget>? children;

  const ProfileHeader({super.key, required this.profile, this.imageLoading = false, this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double imageSize = 96;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ProfileImage(profile: profile, size: imageSize),
              if (imageLoading)
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        GestureDetector(
          onLongPress: () => Clipboard.setData(ClipboardData(text: profile.fullName)),
          child: Text(profile.fullName, style: theme.textTheme.titleLarge),
        ),
        ...(children ?? []),
      ],
    );
  }
}

class OwnProfileHeader extends StatefulWidget {
  final Profile profile;
  final void Function(Profile profile) update;

  const OwnProfileHeader({super.key, required this.profile, required this.update});

  @override
  State<OwnProfileHeader> createState() => _OwnProfileHeaderState();
}

class _OwnProfileHeaderState extends State<OwnProfileHeader> {
  bool _imageLoading = false;

  void _setLoading(bool isLoading) => setState(() => _imageLoading = isLoading);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProfileHeader(
      profile: widget.profile.publicProfile,
      imageLoading: _imageLoading,
      children: [
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
