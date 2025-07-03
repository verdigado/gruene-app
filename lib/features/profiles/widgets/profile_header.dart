import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/profiles/widgets/profile_image_deleter.dart';
import 'package:gruene_app/features/profiles/widgets/profile_image_uploader.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileHeader extends StatefulWidget {
  final Profile profile;
  final ValueChanged<Profile> onProfileUpdated;

  const ProfileHeader({super.key, required this.profile, required this.onProfileUpdated});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _isProcessing = false;

  void _setProcessing(bool isProcessing) {
    setState(() {
      _isProcessing = isProcessing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.profile.image?.thumbnail.url;

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
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null ? Icon(Icons.person, size: 90, color: theme.colorScheme.surface) : null,
              ),
              if (_isProcessing)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${widget.profile.firstName} ${widget.profile.lastName}',
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        ProfileImageUploader(
          profile: widget.profile,
          onProfileUpdated: widget.onProfileUpdated,
          onProcessing: _setProcessing,
        ),
        if (widget.profile.image != null)
          ProfileImageDeleter(
            profile: widget.profile,
            onProfileUpdated: widget.onProfileUpdated,
            onProcessing: _setProcessing,
          ),
      ],
    );
  }
}
