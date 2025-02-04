import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/enums.dart';
import 'package:gruene_app/features/campaigns/models/posters/poster_detail_model.dart';
import 'package:gruene_app/features/campaigns/widgets/close_edit_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class PosterDetail extends StatelessWidget {
  final PosterDetailModel poi;

  const PosterDetail({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    getStatusColor() {
      switch (poi.status) {
        case PosterStatus.ok:
          return ThemeColors.primary;
        case PosterStatus.damaged:
        case PosterStatus.missing:
        case PosterStatus.toBeMoved:
          return Colors.red;
        case PosterStatus.removed:
          return ThemeColors.textDisabled;
      }
    }

    getStatusText() {
      return switch (poi.status) {
        PosterStatus.ok => t.campaigns.poster.status.ok.description,
        PosterStatus.damaged => t.campaigns.poster.status.damaged.description,
        PosterStatus.missing => t.campaigns.poster.status.missing.description,
        PosterStatus.toBeMoved => t.campaigns.poster.status.to_be_moved.description,
        PosterStatus.removed => t.campaigns.poster.status.removed.description,
      };
    }

    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _closeDialog(context, result: ModalDetailResult.edit),
      child: SizedBox(
        height: 250,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: CloseEditWidget(
                onClose: () => _closeDialog(context),
                onEdit: () => _closeDialog(context, result: ModalDetailResult.edit),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 12, bottom: 12),
                  height: 150,
                  width: 120,
                  child: FutureBuilder(
                    future: Future.delayed(
                      Duration.zero,
                      () => poi.thumbnailUrl == null ? null : (thumbnailUrl: poi.thumbnailUrl),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData && !snapshot.hasError) {
                        return Image.asset(CampaignConstants.dummyImageAssetName);
                      }
                      if (snapshot.data!.thumbnailUrl!.isNetworkImageUrl()) {
                        return FadeInImage.assetNetwork(
                          placeholder: CampaignConstants.dummyImageAssetName,
                          image: snapshot.data!.thumbnailUrl!,
                        );
                      } else {
                        return Image.file(
                          File(snapshot.data!.thumbnailUrl!),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${poi.address.street} ${poi.address.houseNumber}\n${poi.address.zipCode} ${poi.address.city}',
                  style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.text),
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: getStatusColor(),
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    SvgPicture.asset(
                      'assets/symbols/posters/svg/poster_${poi.status.name}.svg',
                      height: 18,
                    ),
                    SizedBox(width: 12),
                    Text(
                      getStatusText(),
                      style: theme.textTheme.labelLarge!.copyWith(color: ThemeColors.background),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeDialog(BuildContext context, {ModalDetailResult result = ModalDetailResult.close}) {
    Navigator.maybePop(context, result);
  }
}
