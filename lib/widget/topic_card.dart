import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:gruene_app/gen/assets.gen.dart';
import 'package:gruene_app/gen/fonts.gen.dart';
import 'package:shimmer/shimmer.dart';

class TopicCard extends StatefulWidget {
  String imgageUrl;

  void Function(bool)? onTap;

  String? topic;

  TopicCard({super.key, required this.imgageUrl, this.topic, this.onTap});

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  CachedNetworkImage? img;
  var icon = Icons.add;
  bool checked = false;
  bool imgLoading = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(children: [
        Positioned.fill(
          child: Card(
              semanticContainer: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: widget.imgageUrl,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  placeholder: (context, url) => placeholderCard(),
                  imageBuilder: (context, imageProvider) => Image(
                    image: imageProvider,
                    width: 160,
                    height: 160,
                    fit: BoxFit.fill,
                  ),
                  width: 160,
                  height: 160,
                  fit: BoxFit.fill,
                ),
              )),
        ),
        Positioned(
            top: 15,
            left: 130,
            child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.white,
                mini: true,
                onPressed: () {
                  setState(() {
                    checked = !checked;
                    icon = checked ? icon = Icons.check : Icons.add;
                    if (widget.onTap != null) {
                      widget.onTap!(checked);
                    }
                  });
                },
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ))),
        Positioned.fill(
            child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.topic ?? '',
            style: const TextStyle(
                color: Colors.white,
                fontFamily: FontFamily.bereit,
                fontSize: 26),
          ),
        ))
      ]),
    );
  }

  Shimmer placeholderCard() {
    return Shimmer.fromColors(
        baseColor: const Color(0xFF145F32),
        highlightColor: const Color(0xFF5B8F70),
        child: SizedBox(
          width: 160,
          height: 160,
          child: Card(
            semanticContainer: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ));
  }
}
