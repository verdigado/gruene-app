import 'package:flutter/material.dart';
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
                backgroundColor: Colors.grey[300],
                backgroundImage: widget.profile.image?.thumbnail.url != null
                    ? NetworkImage(widget.profile.image!.thumbnail.url)
                    : null,
                child: widget.profile.image?.thumbnail.url == null
                    ? Icon(Icons.person, size: 90, color: theme.colorScheme.surface)
                    : null,
              ),
              if (_isProcessing)
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
