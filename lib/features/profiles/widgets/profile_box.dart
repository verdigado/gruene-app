import 'package:flutter/material.dart';
import 'package:gruene_app/features/profiles/widgets/profile_box_item.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card.dart';

class ProfileBox extends StatelessWidget {
  final String title;
  final Iterable<ProfileBoxItem> items;

  const ProfileBox({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              ...items.expand((item) => [item, Divider()]).toList()..removeLast(),
            ],
          ),
        ),
      ],
    );
  }
}
