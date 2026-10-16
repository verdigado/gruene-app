import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/dialog_close_button.dart';
import 'package:photo_view/photo_view.dart';

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

void showImageDialog(BuildContext context, String image) async => await showDialog(
  context: context,
  barrierDismissible: true,
  builder: (BuildContext context) => Stack(
    children: [
      Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(image),
          backgroundDecoration: BoxDecoration(color: Colors.transparent),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 6,
          tightMode: true,
        ),
      ),
      SizedBox.expand(child: DialogCloseButton()),
    ],
  ),
);
