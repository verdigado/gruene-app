import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
import 'package:gruene_app/app/widgets/full_width_image.dart';

class BottomSheetTitleRow extends StatelessWidget {
  final void Function()? onClose;
  final Widget? leading;
  final String? title;
  final bool showCloseButton;

  const BottomSheetTitleRow({super.key, this.leading, this.title, this.onClose, this.showCloseButton = true});

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final leading = this.leading;

    return Padding(
      padding: screenPaddingSymmetric(vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          ?leading,
          if (title != null) Text(title, style: Theme.of(context).textTheme.titleMedium),
          Spacer(),
          if (showCloseButton)
            IconButton(icon: const Icon(Icons.close), onPressed: onClose ?? Navigator.of(context).pop),
        ],
      ),
    );
  }
}

class ModalBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final String? image;
  final Widget child;
  final Widget? aside;
  final void Function()? onClose;

  const ModalBottomSheet({
    super.key,
    required this.child,
    this.onClose,
    this.image,
    this.aside,
    this.title,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = this.image;
    final aside = this.aside;

    final titleRow = BottomSheetTitleRow(
      leading: leading,
      title: title,
      onClose: onClose,
      showCloseButton: image == null,
    );

    // The Scaffold is necessary to display snackbars with the bottom sheet opened
    return Scaffold(
      appBar: image == null ? PreferredSize(preferredSize: const Size.fromHeight(64), child: titleRow) : null,
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (image != null) ...[FullWidthImage(image: image, heightRatio: 9 / 16), titleRow],
                Padding(
                  padding: horizontalScreenPadding.copyWith(bottom: DesignConstants.bottomPadding),
                  child: child,
                ),
              ],
            ),
          ),
          if (image != null) DialogCloseButton(onClose: onClose),
          ?aside,
        ],
      ),
    );
  }
}
