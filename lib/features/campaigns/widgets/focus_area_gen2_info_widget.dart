import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/app/services/enums.dart';
import 'package:gruene_app/app/services/gruene_api_campaign_service.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/widgets/close_save_widget.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class FocusAreaGen2InfoWidget extends StatelessWidget {
  final FocusArea focusArea;
  final PoiServiceType poiType;

  const FocusAreaGen2InfoWidget({super.key, required this.focusArea, required this.poiType});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              CloseSaveWidget(onClose: () => Navigator.pop(context)),
              Row(
                children: [
                  Icon(Icons.radar, size: 24),
                  SizedBox(width: 8),
                  Text(focusArea.description ?? '', style: theme.textTheme.titleMedium),
                ],
              ),
              Row(
                children: [
                  Text(
                    _getSubHeadline(focusArea),
                    style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                _getRecommendationWidget(theme),
                _getMilieuWidget(theme),
                _getSpecialCompetitionWidget(theme),
                _getMetaInfoWidget(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getRecommendationWidget(ThemeData theme) {
    var labelActivityType = '';
    var labelActivityRecommendation = '';
    int? activityKey;
    switch (poiType) {
      case PoiServiceType.door:
        labelActivityType = t.campaigns.focus_area.activity1_label;
        labelActivityRecommendation = t.campaigns.focus_area.activity1_recommendation_label;
        activityKey = 1;
      case PoiServiceType.poster:
        labelActivityType = t.campaigns.focus_area.activity2_label;
        labelActivityRecommendation = t.campaigns.focus_area.activity2_recommendation_label;
        activityKey = 2;
      case PoiServiceType.flyer:
        labelActivityType = t.campaigns.focus_area.activity3_label;
        labelActivityRecommendation = t.campaigns.focus_area.activity3_recommendation_label;
        activityKey = 3;
    }

    var activityValue = int.tryParse(
      _getAttribute('${CampaignConstants.focusAreaAttributeActivityBase}$activityKey') ?? '',
    );
    var activityRecommendationValue = _getAttribute(
      CampaignConstants.focusAreaAttributeActivityRecommendation(activityKey),
    );
    if ([activityValue, activityRecommendationValue].every((x) => x == null)) return SizedBox.shrink();

    var content = <Widget>[];
    if (activityValue != null) {
      content.addAll([
        SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(labelActivityType, style: theme.textTheme.bodyMedium?.apply(fontWeightDelta: 2)),
            ),
            Expanded(
              child: StepProgressIndicator(
                totalSteps: 3,
                currentStep: activityValue,
                size: 10,
                selectedColor: ThemeColors.primary,
                unselectedColor: ThemeColors.textLight,
              ),
            ),
          ],
        ),
      ]);
    }
    if (!activityRecommendationValue.isNullOrEmpty()) {
      content.addAll([
        SizedBox(height: 8),
        Row(
          children: [Text(labelActivityRecommendation, style: theme.textTheme.bodyMedium?.apply(fontWeightDelta: 2))],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                _replaceUnicode(activityRecommendationValue!),
                style: theme.textTheme.bodySmall?.apply(color: ThemeColors.textDark),
                softWrap: true,
              ),
            ),
          ],
        ),
      ]);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.campaign_outlined),
                SizedBox(width: 8),
                Text(t.campaigns.focus_area.intensity_recommendation, style: theme.textTheme.titleSmall),
              ],
            ),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _getMilieuWidget(ThemeData theme) {
    final milieuValueImages = ['left', 'mid-left', 'mid', 'mid-right', 'right'];

    var milieuValue = int.tryParse(_getAttribute(CampaignConstants.focusAreaAttributeMilieuIndicator) ?? '');
    var milieuShortDescription = _getAttribute(CampaignConstants.focusAreaAttributeMilieuShortDescription);
    var milieuLongDescription = _getAttribute(CampaignConstants.focusAreaAttributeMilieuLongDescription);
    var milieuAddOnAgeLabel = _getAttribute(CampaignConstants.focusAreaAttributeMilieuAddOnAgeLabel);
    if (!milieuAddOnAgeLabel.isNullOrEmpty()) milieuLongDescription = '$milieuLongDescription $milieuAddOnAgeLabel';
    if ([milieuValue, milieuShortDescription, milieuLongDescription].every((x) => x == null)) return SizedBox.shrink();

    var content = <Widget>[];
    if (milieuValue != null) {
      content.addAll([
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterSlider(
                    values: [milieuValue.toDouble()],
                    max: 5,
                    min: 1,
                    handlerHeight: 25,
                    handler: FlutterSliderHandler(
                      decoration: BoxDecoration(),
                      child: SizedBox(
                        width: 5,
                        height: 20,
                        child: SvgPicture.asset('assets/symbols/focus_areas/milieu_indicator.svg'),
                      ),
                    ),
                    jump: true,
                    step: FlutterSliderStep(isPercentRange: false),
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBar: BoxDecoration(color: Colors.transparent),
                      activeDisabledTrackBarColor: Colors.transparent,
                    ),
                    disabled: true,
                    tooltip: FlutterSliderTooltip(disabled: true),
                    hatchMark: FlutterSliderHatchMark(
                      density: 0.04,
                      displayLines: true,
                      linesDistanceFromTrackBar: -8,
                      bigLine: FlutterSliderSizedBox(
                        height: 12,
                        width: 2,
                        decoration: BoxDecoration(color: ThemeColors.textDisabled),
                      ),
                      smallLine: FlutterSliderSizedBox(
                        height: 10,
                        width: 2,
                        decoration: BoxDecoration(color: ThemeColors.textDisabled),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Text(
                      t.campaigns.focus_area.progressive,
                      style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text(
                      t.campaigns.focus_area.conservative,
                      style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]);
    }

    if ([milieuValue, milieuShortDescription].every((x) => x != null)) {
      content.addAll([
        SizedBox(height: 8),

        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(color: ThemeColors.sun),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/symbols/focus_areas/milieu_indicator_${milieuValueImages[milieuValue! - 1]}.svg',
                height: 16,
                width: 16,
              ),
              SizedBox(width: 8),
              Text(
                milieuShortDescription ?? '',
                style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDark),
              ),
            ],
          ),
        ),
      ]);
    }

    if ([milieuLongDescription].every((x) => x != null)) {
      content.addAll([
        SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Text(
                milieuLongDescription!,
                style: theme.textTheme.bodySmall?.apply(color: ThemeColors.textDark),
                softWrap: true,
              ),
            ),
          ],
        ),
      ]);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.speed_outlined),
                SizedBox(width: 8),
                Text(t.campaigns.focus_area.milieu, style: theme.textTheme.titleSmall),
              ],
            ),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _getSpecialCompetitionWidget(ThemeData theme) {
    var specialPoliticalSituationLabel = [
      _getAttribute(CampaignConstants.focusAreaAttributeSpecialPoliticalSituationLabel(1)),
      _getAttribute(CampaignConstants.focusAreaAttributeSpecialPoliticalSituationLabel(2)),
    ].where((x) => !x.isNullOrEmpty()).join(' ').trim();

    if ([specialPoliticalSituationLabel].every((x) => x.isNullOrEmpty())) return SizedBox.shrink();
    var content = <Widget>[];

    if ([specialPoliticalSituationLabel].every((x) => !x.isNullOrEmpty())) {
      content.addAll([
        SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Text(
                specialPoliticalSituationLabel,
                style: theme.textTheme.bodySmall?.apply(color: ThemeColors.textDark),
                softWrap: true,
              ),
            ),
          ],
        ),
      ]);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: ThemeColors.background,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outlined),
                SizedBox(width: 8),
                Text(t.campaigns.focus_area.special_competition, style: theme.textTheme.titleSmall),
              ],
            ),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _getMetaInfoWidget(ThemeData theme) {
    return FutureBuilder(
      future: _getCampaignData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return CircularProgressIndicator();
        return Text(
          t.campaigns.focus_area.meta_info(
            campaign: snapshot.data!.name,
            updatedAt: focusArea.createdAt.getAsLocalDateString(),
            focusAreaId: focusArea.key,
          ),
          style: theme.textTheme.labelMedium?.apply(color: ThemeColors.textDisabled),
        );
      },
    );
  }

  String _getSubHeadline(FocusArea focusArea) {
    var locationKV = _getAttribute(CampaignConstants.focusAreaAttributeLocationKV);
    var textItems = [
      _getAttribute(CampaignConstants.focusAreaAttributeLocationMunicipality),
      locationKV != null ? t.campaigns.focus_area.location_kv(name: locationKV) : null,
    ];
    return textItems.where((x) => x != null).join(', ');
  }

  String? _getAttribute(String key) {
    var attr = focusArea.attributes as Map<String, dynamic>;
    if (attr.containsKey(key)) {
      return attr[key] as String;
    } else {
      return null;
    }
  }

  String _replaceUnicode(String inputText) {
    final Pattern unicodePattern = RegExp(r'U\+([0-9A-Fa-f]{4,6})');
    final String newStr = inputText.replaceAllMapped(unicodePattern, (Match unicodeMatch) {
      final int hexCode = int.parse(unicodeMatch.group(1)!, radix: 16);
      final unicode = String.fromCharCode(hexCode);
      return unicode;
    });
    return newStr;
  }

  Future<Campaign> _getCampaignData() async {
    var campaignService = GetIt.I<GrueneApiCampaignService>();
    return await campaignService.getCampaign(focusArea.campaignId);
  }
}
