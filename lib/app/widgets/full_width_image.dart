import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullWidthImage extends StatelessWidget {
  final String image;
  final double heightRatio;

  const FullWidthImage({super.key, required this.image, this.heightRatio = 0.75});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).width * heightRatio),
      child: InkWell(
        onTap: () => showImageDialog(context, image),
        child: CachedNetworkImage(
          placeholder: (_, _) => SizedBox(height: double.infinity),
          imageUrl: image,
          fit: BoxFit.fitWidth,
          width: double.infinity,
        ),
      ),
    );
  }
}

void showImageDialog(BuildContext context, String image) async {
  final theme = Theme.of(context);
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => Stack(
      children: [
        CachedNetworkImage(imageUrl: image, fit: BoxFit.contain),
        Container(
          alignment: Alignment.topRight,
          padding: EdgeInsets.all(8),
          width: double.infinity,
          height: 64,
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.surface,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: Navigator.of(context).pop,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}
