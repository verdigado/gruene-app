import 'package:gruene_app/app/geo/geo.dart';
import 'package:gruene_app/app/utils/logger.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:tuple/tuple.dart';
import 'package:turf/turf.dart';

class MapHelper {
  /// Properties of the poi marker layer. Since [MapLibreMapController.setLayerProperties] resets all
  /// properties not given, the complete set has to be passed when changing e.g. the opacity.
  static SymbolLayerProperties poiMarkerLayerProperties({double iconOpacity = 1}) => SymbolLayerProperties(
    iconImage: ['get', CampaignConstants.featurePropertyStatusType],
    iconSize: [
      Expressions.interpolate,
      ['linear'],
      [Expressions.zoom],
      11,
      1,
      16,
      2,
    ],
    iconAllowOverlap: true,
    iconOpacity: iconOpacity,
  );

  /// Properties of the polling station layer, see [poiMarkerLayerProperties]
  static SymbolLayerProperties pollingStationLayerProperties({double? iconOpacity = 1}) => SymbolLayerProperties(
    iconImage: CampaignConstants.pollingStationSourceName,
    iconSize: [
      Expressions.interpolate,
      ['linear'],
      [Expressions.zoom],
      11,
      1,
      16,
      2,
    ],
    iconAllowOverlap: true,
    iconOpacity: iconOpacity,
  );

  static LatLng extractLatLngFromFeature(dynamic rawFeature) {
    final feature = rawFeature as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    return coordinates.cast<double>().toLatLng();
  }

  static num _calculateDistance(Feature<GeometryObject> turfFeature, Point targetPoint) {
    try {
      switch (turfFeature.geometry?.type) {
        case GeoJSONObjectType.point:
          return distance(turfFeature.geometry as Point, targetPoint);
        case GeoJSONObjectType.lineString:
          return _calculateDistance(
            nearestPointOnLine(turfFeature.geometry as LineString, targetPoint) as Feature<GeometryObject>,
            targetPoint,
          );
        case GeoJSONObjectType.polygon:
          return _calculateDistance(
            polygonToLine(turfFeature.geometry as Polygon) as Feature<GeometryObject>,
            targetPoint,
          );

        default:
          throw UnimplementedError();
      }
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  static dynamic getClosestFeature(List<dynamic> features, LatLng target) {
    // double calculateDistance(LatLng point1, LatLng point2) {
    //   // We use the equirectangular distance approximation for a very fast comparison.
    //   // LatLng encodes degrees, so we need to convert to radians.
    //   const double degreeToRadians = 180.0 / math.pi;
    //   const double earthRadius = 6371; // radius of the earth in km
    //   final double x =
    //       (point2.longitude - point1.longitude) *
    //       degreeToRadians *
    //       math.cos(0.5 * (point2.latitude + point1.latitude) * degreeToRadians);
    //   final double y = (point2.latitude - point1.latitude) * degreeToRadians;
    //   return earthRadius * math.sqrt(x * x + y * y);
    // }

    final minimalDistanceFeature = features.fold(null, (
      Tuple2<dynamic, num>? currentFeatureWithDistance,
      dynamic nextFeature,
    ) {
      final turfFeature = Feature.fromJson(nextFeature as Map<String, dynamic>);
      final nextFeatureDistance = _calculateDistance(turfFeature, target.toPoint());

      if (currentFeatureWithDistance != null && currentFeatureWithDistance.item2 < nextFeatureDistance) {
        return currentFeatureWithDistance;
      }
      return Tuple2(nextFeature, nextFeatureDistance);
    });

    return minimalDistanceFeature?.item1;
  }

  static String extractPoiIdFromFeature(Map<String, dynamic> feature) {
    final id = feature['id'].toString();
    return id;
  }

  static bool extractIsCachedFromFeature(Map<String, dynamic> feature) {
    if (feature['properties'] == null) return false;
    final properties = feature['properties'] as Map<String, dynamic>;
    if (properties[CampaignConstants.featurePropertyIsVirtual] == null) return false;
    return bool.parse(properties[CampaignConstants.featurePropertyIsVirtual].toString());
  }

  static String extractStatusTypeFromFeature(Map<String, dynamic> feature) {
    if (feature['properties'] == null) return '';
    final properties = feature['properties'] as Map<String, dynamic>;
    if (properties[CampaignConstants.featurePropertyStatusType] == null) return '';
    return properties[CampaignConstants.featurePropertyStatusType].toString();
  }
}
