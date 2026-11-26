import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/constants.dart';
import 'package:gruene_app/app/constants/design_constants.dart';
import 'package:gruene_app/app/widgets/alert.dart';
import 'package:gruene_app/app/widgets/dialog.dart';
import 'package:gruene_app/app/widgets/full_width_image.dart';
import 'package:gruene_app/i18n/translations.g.dart';

Future<T?> showModalAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T?>(
  context: context,
  useRootNavigator: true,
  // Scaffold always fills the max space available without taking e.g. rounded corners into account
  clipBehavior: Clip.antiAlias,
  // Swiping down pops the sheet without consulting the PopScope, so unsaved changes would be discarded without asking
  enableDrag: false,
  builder: builder,
);

class ModalBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final String? image;
  final Widget child;
  final Widget? aside;
  final bool hasUnsavedChanges;
  final void Function()? onClose;
  final void Function()? goBack;

  const ModalBottomSheet({
    super.key,
    required this.child,
    this.onClose,
    this.goBack,
    this.image,
    this.aside,
    this.title,
    this.leading,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;
    final image = this.image;
    final aside = this.aside;
    final goBack = this.goBack;

    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) discardChanges(context);
      },
      // The Scaffold is necessary to display snackbars with the bottom sheet opened
      child: Scaffold(
        appBar: image == null
            ? AppBar(
                automaticallyImplyLeading: false,
                leading: leading ?? (goBack != null ? BackButton(onPressed: goBack) : null),
                title: title != null ? Text(title, style: theme.textTheme.titleMedium) : null,
                actions: [CloseButton(onPressed: onClose ?? Navigator.of(context).maybePop)],
                titleSpacing: 0,
                scrolledUnderElevation: 0,
              )
            : null,
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
                  if (image != null) ...[
                    FullWidthImage(image: image, heightRatio: 9 / 16),
                    if (title != null) Text(title, style: theme.textTheme.titleMedium),
                  ],
                  Padding(
                    padding: horizontalScreenPadding.copyWith(bottom: DesignConstants.bottomPadding),
                    child: child,
                  ),
                ],
              ),
            ),
            if (image != null && goBack != null)
              DialogButtonContainer(
                alignment: Alignment.topLeft,
                child: BackButton(onPressed: goBack),
              ),
            if (image != null) DialogCloseButton(onClose: onClose),
            ?aside,
          ],
        ),
      ),
    );
  }
}

void discardChanges(BuildContext context) => showConfirmationDialog(
  context,
  title: t.common.confirmDiscard.title,
  content: Text(t.common.confirmDiscard.text),
  label: t.common.actions.discard,
  onConfirmed: () => Navigator.pop(context),
);
