import 'package:flutter/material.dart';
import 'package:gruene_app/features/profiles/widgets/profile_box_item.dart';
import 'package:gruene_app/features/profiles/widgets/profile_card.dart';

class ProfileBox extends StatelessWidget {
  final String title;
  final List<ProfileBoxItem> items;

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
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 12),
                ...items.expand((item) => [item, Divider()]).toList()..removeLast(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
