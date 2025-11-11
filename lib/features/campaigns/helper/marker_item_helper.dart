import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:turf/transform.dart';

class MarkerItemHelper {
  static FeatureCollection transformListToGeoJson(List<MarkerItemModel> markerItems) {
    return FeatureCollection(features: markerItems.map(transformMarkerItemToGeoJson).toList());
  }

  static Feature<Point> transformMarkerItemToGeoJson(MarkerItemModel markerItem) {
    return Feature<Point>(
      id: markerItem.id,
      properties: <String, dynamic>{
        CampaignConstants.featurePropertyStatusType: markerItem.status,
        CampaignConstants.featurePropertyIsVirtual: markerItem.isVirtual,
      },
      geometry: Point(coordinates: Position(markerItem.location.longitude, markerItem.location.latitude)),
    );
  }
}
