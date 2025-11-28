import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/full_width_image.dart';

class ModalBottomSheet extends StatelessWidget {
  final String? image;
  final Widget child;
  final Widget? aside;
  final void Function() onClose;

  const ModalBottomSheet({super.key, required this.child, required this.onClose, this.image, this.aside});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = this.image;
    final aside = this.aside;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  if (image != null) FullWidthImage(image: image, heightRatio: 9 / 16),
                  Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 60), child: child),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.all(8),
              width: double.infinity,
              height: 64,
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (aside != null) aside,
          ],
        ),
      ),
    );
  }
}
