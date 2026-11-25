import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

StandEntryModel _entry(String id, int flyerCount) => StandEntryModel(
  id: id,
  startAt: DateTime(2026, 11, 7, 10),
  endAt: DateTime(2026, 11, 7, 12),
  flyerCount: flyerCount,
);

StandDetailModel _stand({
  required int flyerCountTotal,
  required List<StandEntryModel> entries,
  bool isCached = false,
}) => StandDetailModel(
  id: '4711',
  address: AddressModel(street: 'Hauptstraße', houseNumber: '1', zipCode: '10115', city: 'Berlin'),
  location: LatLng(52.52, 13.405),
  name: 'Marktplatz',
  flyerCountTotal: flyerCountTotal,
  entries: entries,
  photos: const [],
  createdAt: '01.11.2026 10:00',
  isCached: isCached,
);

void main() {
  group('displayedFlyerTotal', () {
    test('is the total from the API for a stand without queued changes', () {
      final stand = _stand(flyerCountTotal: 250, entries: [_entry('1', 80), _entry('2', 120)]);

      expect(stand.displayedFlyerTotal, 250);
    });

    test('is the sum of the Termine while changes to the stand are queued', () {
      final stand = _stand(flyerCountTotal: 250, entries: [_entry('1', 80), _entry('2', 120)], isCached: true);

      expect(stand.displayedFlyerTotal, 200);
    });

    test('is 0 for a queued stand whose Termine have no flyers', () {
      final stand = _stand(flyerCountTotal: 250, entries: [_entry('1', 0)], isCached: true);

      expect(stand.displayedFlyerTotal, 0);
    });
  });
}
