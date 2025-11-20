import 'package:flutter/material.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/show_snack_bar.dart';
import 'package:gruene_app/i18n/translations.g.dart';

OverlayEntry? _overlay;

void showLoadingOverlay(BuildContext context) {
  _overlay = OverlayEntry(
    builder: (_) => Stack(
      children: [
        ModalBarrier(dismissible: false, color: ThemeColors.text.withValues(alpha: 0.5)),
        Center(child: CircularProgressIndicator()),
      ],
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(_overlay!);
}

void hideLoadingOverlay() {
  _overlay?.remove();
  _overlay = null;
}

Future<T?> tryAndNotify<T>({
  required Future<T> Function() function,
  required BuildContext context,
  required String successMessage,
  String? errorMessage,
}) async {
  showLoadingOverlay(context);
  try {
    final value = await function();
    if (context.mounted) {
      showSnackBar(context, successMessage);
    }
    return value;
  } catch (error) {
    if (context.mounted) {
      showSnackBar(context, errorMessage ?? t.error.unknownError);
    }
  } finally {
    hideLoadingOverlay();
  }
  return null;
}
