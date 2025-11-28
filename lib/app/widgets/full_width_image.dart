import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';

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

void showImageDialog(BuildContext context, String image) async => await showDialog<void>(
  context: context,
  barrierDismissible: true,
  builder: (BuildContext context) => Stack(
    children: [
      CachedNetworkImage(imageUrl: image, fit: BoxFit.contain),
      DialogCloseButton(),
    ],
  ),
);
