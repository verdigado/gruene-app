import 'package:flutter/material.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Profile profile;

  const ProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 90,
          child: CircleAvatar(
            radius: 45,
            backgroundColor: Colors.grey,
            backgroundImage: profile.image?.thumbnail.url != null ? NetworkImage(profile.image!.thumbnail.url) : null,
            child: profile.image?.thumbnail.url == null ? Icon(Icons.person, size: 90, color: Colors.white) : null,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '${profile.firstName} ${profile.lastName}',
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
