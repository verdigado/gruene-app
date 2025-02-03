import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/features/campaigns/helper/media_helper.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_list_item_model.dart';
import 'package:gruene_app/features/campaigns/screens/map_consumer.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class MyPosterListScreen extends StatefulWidget {
  final List<PosterListItemModel> myPosters;
  final GetPoiCallback<PosterDetailModel> getPoi;
  final GetPoiEditWidgetCallback<PosterDetailModel> getPoiEdit;
  final Future<PosterListItemModel> Function(String id) reloadPosterListItem;

  const MyPosterListScreen({
    super.key,
    required this.myPosters,
    required this.getPoi,
    required this.getPoiEdit,
    required this.reloadPosterListItem,
  });

  @override
  State<MyPosterListScreen> createState() => _MyPosterListScreenState();
}

class _MyPosterListScreenState extends State<MyPosterListScreen> {
  late List<PosterListItemModel> currentPosters;
  @override
  void initState() {
    currentPosters = widget.myPosters;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 52,
            padding: EdgeInsets.only(left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.campaigns.poster.my_posters_title,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          ListView.builder(
            itemBuilder: (context, index) => getPosterListItem(currentPosters[index], context),
            itemCount: currentPosters.length,
            itemExtent: 148,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }

  Widget getPosterListItem(PosterListItemModel myPoster, BuildContext context) {
    final theme = Theme.of(context);
    final currentSize = MediaQuery.of(context).size;

    final cardHeight = 148.0;
    final imageHeight = 77.0;
    final addressBoxWidth = currentSize.width - 166;

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      shadowColor: ThemeColors.textDisabled,
      child: SizedBox(
        height: cardHeight,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    myPoster.status,
                    style: theme.textTheme.bodyMedium!.apply(
                      fontWeightDelta: 3,
                      color: ThemeColors.textWarning,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _editPoster(myPoster),
                    child: Text(
                      t.common.actions.edit,
                      style: theme.textTheme.bodyMedium!.apply(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Container(
                      height: imageHeight,
                      width: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: FutureBuilder(
                          future: Future.delayed(Duration.zero, () => (thumbnailUrl: myPoster.thumbnailUrl)),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData && !snapshot.hasError) {
                              return Image.asset(CampaignConstants.dummyImageAssetName);
                            }

                            return GestureDetector(
                              onTap: () => _showPictureFullView(myPoster.imageUrl!),
                              child: snapshot.data!.thumbnailUrl!.isNetworkImageUrl()
                                  ? FadeInImage.assetNetwork(
                                      placeholder: CampaignConstants.dummyImageAssetName,
                                      image: snapshot.data!.thumbnailUrl!,
                                    )
                                  : Image.file(
                                      File(snapshot.data!.thumbnailUrl!),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                      height: imageHeight,
                      width: addressBoxWidth,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: addressBoxWidth,
                                child: Text(
                                  '${myPoster.address.street} ${myPoster.address.houseNumber}'.trim(),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: theme.textTheme.titleMedium!.copyWith(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: addressBoxWidth,
                                child: Text(
                                  '${myPoster.address.zipCode} ${myPoster.address.city}'.trim(),
                                  style: theme.textTheme.titleMedium!.copyWith(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 35,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    myPoster.lastChangeStatus,
                                    style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.textDisabled),
                                  ),
                                  Text(
                                    myPoster.lastChangeDateTime,
                                    style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.textDisabled),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPictureFullView(String imageUrl) {
    MediaHelper.showPictureInFullView(
      context,
      imageUrl.isNetworkImageUrl() ? NetworkImage(imageUrl) : FileImage(File(imageUrl)),
    );
  }

  void _editPoster(PosterListItemModel myPoster) async {
    var poi = await widget.getPoi(myPoster.id);
    _showEdit(poi);
  }

  void _showEdit(PosterDetailModel poi) async {
    var result = await MapConsumer.showModalEditForm(context, () => widget.getPoiEdit(poi));
    if (result == null) return;

    switch (result) {
      case ModalEditResult.save:
        var updatedItem = await widget.reloadPosterListItem(poi.id);
        setState(() {
          var index = currentPosters.indexWhere((p) => p.id == updatedItem.id);
          currentPosters[index] = updatedItem;
        });
      case ModalEditResult.delete:
        setState(() {
          currentPosters.retainWhere((p) => p.id != poi.id);
        });
      default:
    }
  }
}
