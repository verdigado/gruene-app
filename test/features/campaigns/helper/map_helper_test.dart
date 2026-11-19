import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_constants.dart';
import 'package:gruene_app/features/campaigns/helper/map_helper.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// A square polygon feature from ([west], [south]) to ([east], [north]), coordinates as [lng, lat].
Map<String, dynamic> _square(String id, double west, double south, double east, double north) => {
  'type': 'Feature',
  'id': id,
  'properties': <String, dynamic>{},
  'geometry': {
    'type': 'Polygon',
    'coordinates': [
      [
        [west, south],
        [east, south],
        [east, north],
        [west, north],
        [west, south],
      ],
    ],
  },
};

/// A straight line feature from ([lng1], [lat1]) to ([lng2], [lat2]).
Map<String, dynamic> _line(String id, double lng1, double lat1, double lng2, double lat2) => {
  'type': 'Feature',
  'id': id,
  'properties': <String, dynamic>{},
  'geometry': {
    'type': 'LineString',
    'coordinates': [
      [lng1, lat1],
      [lng2, lat2],
    ],
  },
};

List<String> _ids(List<Map<String, dynamic>> features) => features.map((f) => f['id'] as String).toList();

void main() {
  group('filterPolygonsContaining', () {
    final outer = _square('outer', 13.0, 52.0, 13.1, 52.1);
    final inner = _square('inner', 13.04, 52.04, 13.06, 52.06);
    final neighbour = _square('neighbour', 13.1, 52.0, 13.2, 52.1);

    test('keeps only the areas that contain the tap', () {
      final result = MapHelper.filterPolygonsContaining([outer, inner, neighbour], LatLng(52.05, 13.05));

      expect(_ids(result), ['outer', 'inner']);
    });

    test('drops a neighbouring area the touch target only touches', () {
      final result = MapHelper.filterPolygonsContaining([outer, neighbour], LatLng(52.05, 13.09));

      expect(_ids(result), ['outer']);
    });

    test('returns all areas if none contains the tap', () {
      final result = MapHelper.filterPolygonsContaining([outer, neighbour], LatLng(51.99, 13.1));

      expect(_ids(result), ['outer', 'neighbour']);
    });
  });

  group('sortByDistance', () {
    test('sorts routes by distance from the tap, the closest first', () {
      final far = _line('far', 13.0, 52.02, 13.1, 52.02);
      final near = _line('near', 13.0, 52.001, 13.1, 52.001);
      final middle = _line('middle', 13.0, 52.01, 13.1, 52.01);

      final result = MapHelper.sortByDistance([far, near, middle], LatLng(52.0, 13.05));

      expect(_ids(result), ['near', 'middle', 'far']);
    });

    test('does not change the given list', () {
      final features = [_line('far', 13.0, 52.02, 13.1, 52.02), _line('near', 13.0, 52.001, 13.1, 52.001)];

      MapHelper.sortByDistance(features, LatLng(52.0, 13.05));

      expect(_ids(features), ['far', 'near']);
    });
  });

  group('extract name and type label', () {
    test('reads name and type label from the feature properties', () {
      final feature = _line('route', 13.0, 52.0, 13.1, 52.0)
        ..['properties'] = {
          CampaignConstants.featurePropertyName: 'Route Nord',
          CampaignConstants.featurePropertyTypeLabel: 'Flyer-Route',
        };

      expect(MapHelper.extractNameFromFeature(feature), 'Route Nord');
      expect(MapHelper.extractTypeLabelFromFeature(feature), 'Flyer-Route');
    });

    test('returns an empty text if the properties are missing', () {
      final feature = _line('route', 13.0, 52.0, 13.1, 52.0)..remove('properties');

      expect(MapHelper.extractNameFromFeature(feature), '');
      expect(MapHelper.extractTypeLabelFromFeature(feature), '');
    });
  });
}
