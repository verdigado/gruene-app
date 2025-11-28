import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
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
            DialogCloseButton(),
            if (aside != null) aside,
          ],
        ),
      ),
    );
  }
}
