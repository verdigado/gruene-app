import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/converters.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

void main() {
  group('route types loaded per tab', () {
    test('the door tab loads door and flyer routes', () {
      expect(PoiServiceType.door.toRoutesApiGetTypes(), [RouteType.house, RouteType.flyerSpot]);
    });

    test('the poster tab loads only poster routes', () {
      expect(PoiServiceType.poster.toRoutesApiGetTypes(), [RouteType.poster]);
    });
  });

  group('action area types loaded per tab', () {
    test('the door tab loads door and flyer action areas', () {
      expect(PoiServiceType.door.toApiAreasGetTypes(), [AreaType.house, AreaType.flyerSpot]);
    });

    test('the poster tab loads only poster action areas', () {
      expect(PoiServiceType.poster.toApiAreasGetTypes(), [AreaType.poster]);
    });
  });
}
