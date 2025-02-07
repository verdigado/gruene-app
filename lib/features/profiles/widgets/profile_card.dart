import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;

  const ProfileCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              offset: Offset(0, 1),
              blurRadius: 12,
            ),
          ],
        ),
        child: Card(
          color: theme.colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: child),
        ),
      ),
    );
  }
}
