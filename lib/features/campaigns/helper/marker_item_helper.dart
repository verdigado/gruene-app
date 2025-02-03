import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/models/map_layer_model.dart';
import 'package:gruene_app/features/campaigns/models/marker_item_model.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:turf/transform.dart';

class MarkerItemHelper {
  static FeatureCollection transformListToGeoJson(List<MarkerItemModel> markerItems) {
    return FeatureCollection(features: markerItems.map(transformMarkerItemToGeoJson).toList());
  }

  static Feature<Point> transformMarkerItemToGeoJson(MarkerItemModel markerItem) {
    return Feature<Point>(
      id: markerItem.id,
      properties: <String, dynamic>{
        'status_type': markerItem.status,
        'is_virtual': markerItem.isVirtual,
      },
      geometry: Point(coordinates: Position(markerItem.location.longitude, markerItem.location.latitude)),
    );
  }

  static FeatureCollection transformMapLayerDataToGeoJson(List<MapLayerModel> mapLayerData) {
    return FeatureCollection(features: mapLayerData.map(transformMapLayerModelToGeoJson).toList());
  }

  static Feature<Polygon> transformMapLayerModelToGeoJson(MapLayerModel mapLayerModel) {
    var opacities = [0, 0.15, 0.4, 0.55, 0.75];
    final scoreColor = ThemeColors.focusAreaBaseColor.toHexStringRGB();
    var score = mapLayerModel.score.toInt();
    var scoreIndex = score - 1;
    return Feature<Polygon>(
      id: mapLayerModel.id,
      properties: <String, dynamic>{
        'id': mapLayerModel.id.toString(),
        'score_color': scoreColor,
        'score_opacity': scoreIndex > opacities.length || scoreIndex < 0 ? opacities.first : opacities[scoreIndex],
        'info': mapLayerModel.description,
        'score_info': CampaignConstants.scoreInfos[score],
      },
      geometry: Polygon(coordinates: mapLayerModel.coords),
    );
  }
}
