import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/poi_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_create_model.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_photo_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/services/api/action_area_api_service.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/door_api_service.dart';
import 'package:gruene_app/app/services/api/enums.dart';
import 'package:gruene_app/app/services/api/poster_api_service.dart';
import 'package:gruene_app/app/services/api/route_api_service.dart';
import 'package:gruene_app/app/services/api/stand_api_service.dart';
import 'package:gruene_app/app/services/campaign_action_database.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/utils/file_cache_manager.dart';
import 'package:gruene_app/features/campaigns/core/cache/campaign_action_cache.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:turf/turf.dart' as turf;

class _MockStandApiService extends Mock implements StandApiService {}

class _MockPosterApiService extends Mock implements PosterApiService {}

class _MockDoorApiService extends Mock implements DoorApiService {}

class _MockRouteApiService extends Mock implements RouteApiService {}

class _MockActionAreaApiService extends Mock implements ActionAreaApiService {}

class _MockFileManager extends Mock implements FileManager {}

final _address = AddressModel(street: 'Hauptstraße', houseNumber: '1', zipCode: '10115', city: 'Berlin');
final _location = LatLng(52.52, 13.405);

StandEntryCreateModel _newEntry(DateTime startAt, {int? flyerCount}) =>
    StandEntryCreateModel(startAt: startAt, endAt: startAt.add(const Duration(hours: 2)), flyerCount: flyerCount);

StandCreateModel _newStand() => StandCreateModel(
  location: _location,
  address: _address,
  name: 'Marktplatz',
  firstEntry: _newEntry(DateTime(2026, 11, 7, 10), flyerCount: 80),
  campaignId: 'campaign-1',
);

/// A stand as loaded from the API, with a flyer total that is not the sum of its Termine.
StandDetailModel _serverStand() => StandDetailModel(
  id: '4711',
  address: _address,
  location: _location,
  name: 'Marktplatz',
  flyerCountTotal: 250,
  entries: [
    StandEntryModel(id: '2', startAt: DateTime(2026, 11, 14, 10), endAt: DateTime(2026, 11, 14, 12), flyerCount: 120),
    StandEntryModel(id: '1', startAt: DateTime(2026, 11, 7, 10), endAt: DateTime(2026, 11, 7, 12), flyerCount: 80),
  ],
  photos: const [],
  createdAt: '01.11.2026 10:00',
);

void main() {
  late _MockStandApiService standApi;
  late CampaignActionCache cache;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(_newStand());
    registerFallbackValue(PosterCreateModel(address: _address, location: _location, campaignId: ''));
    registerFallbackValue(_newEntry(DateTime(2026)));
    registerFallbackValue(StandEntryUpdateModel(entryId: '', startAt: DateTime(2026), endAt: DateTime(2026)));
    registerFallbackValue(
      StandUpdateModel(id: '', address: _address, location: _location, name: '', oldStandDetail: _serverStand()),
    );
  });

  setUp(() async {
    final db = await CampaignActionDatabase.instance.database;
    await db.delete(CampaignActionFields.tableName);

    standApi = _MockStandApiService();
    final fileManager = _MockFileManager();
    when(fileManager.clearAllFiles).thenAnswer((_) async {});
    GetIt.I
      ..registerSingleton<StandApiService>(standApi)
      ..registerSingleton<PosterApiService>(_MockPosterApiService())
      ..registerSingleton<DoorApiService>(_MockDoorApiService())
      ..registerSingleton<RouteApiService>(_MockRouteApiService())
      ..registerSingleton<ActionAreaApiService>(_MockActionAreaApiService())
      ..registerSingleton<FileManager>(fileManager);

    when(() => standApi.createNewStand(any()))
        .thenAnswer((_) async => PoiDetailModel(id: 4711, status: 'stand', location: _location));
    when(() => standApi.addStandEntry(any(), any())).thenAnswer((_) async => _serverStand());
    when(() => standApi.updateStandEntry(any(), any())).thenAnswer((_) async => _serverStand());
    when(() => standApi.deleteStandEntry(any(), any())).thenAnswer((_) async => _serverStand());

    cache = CampaignActionCache();
    cache.takeRefusedActionCount(); // the cache is a singleton
  });

  tearDown(GetIt.I.reset);

  Future<String> storeQueuedStand() async {
    final marker = await cache.storeNewPoi(PoiCacheType.stand, _newStand());
    return marker.id.toString();
  }

  test('a stand created offline shows on the map and in its detail', () async {
    final standId = await storeQueuedStand();

    final markers = await cache.getLayerItems(PoiCacheType.stand);
    expect(markers.single.id.toString(), standId);
    expect(await cache.isCached(standId, PoiCacheType.stand), isTrue);

    final stand = await cache.getPoiAsStandDetail(standId);
    expect(stand.name, 'Marktplatz');
    expect(stand.entries.single.flyerCount, 80);
    expect(stand.isCached, isTrue);
  });

  test('a Termin added to a stand created offline is sent after the stand', () async {
    final standId = await storeQueuedStand();
    final queuedStand = await cache.getPoiAsStandDetail(standId);
    await cache.addStandEntry(standId, _newEntry(DateTime(2026, 11, 14, 10), flyerCount: 50), queuedStand);

    await cache.flushCache();

    verifyInOrder([
      () => standApi.createNewStand(any()),
      () => standApi.addStandEntry('4711', any(that: isA<StandEntryCreateModel>())),
    ]);
    expect(await cache.getCachedActionCount(), 0);
  });

  test('a stand changed while still in the queue is sent with its new id after it is created', () async {
    when(() => standApi.updateStand(any()))
        .thenAnswer((_) async => PoiDetailModel(id: 4711, status: 'stand', location: _location));
    final standId = await storeQueuedStand();
    final queuedStand = await cache.getPoiAsStandDetail(standId);
    StandUpdateModel rename(String name) =>
        StandUpdateModel(id: standId, address: _address, location: _location, name: name, oldStandDetail: queuedStand);
    await cache.updatePoi(PoiCacheType.stand, rename('Wochenmarkt'));
    await cache.updatePoi(PoiCacheType.stand, rename('Rathausplatz'));

    expect((await cache.getPoiAsStandDetail(standId)).name, 'Rathausplatz');
    await cache.flushCache();

    final update = verify(() => standApi.updateStand(captureAny())).captured.single as StandUpdateModel;
    expect(update.id, '4711');
    expect(update.name, 'Rathausplatz');
  });

  test('changing the first Termin of a stand created offline changes the queued stand', () async {
    final standId = await storeQueuedStand();
    final firstEntry = (await cache.getPoiAsStandDetail(standId)).entries.single;

    await cache.updateStandEntry(
      standId,
      StandEntryUpdateModel(
        entryId: firstEntry.id,
        startAt: firstEntry.startAt,
        endAt: firstEntry.endAt,
        flyerCount: 30,
      ),
      await cache.getPoiAsStandDetail(standId),
    );
    await cache.flushCache();

    final created = verify(() => standApi.createNewStand(captureAny())).captured.single as StandCreateModel;
    expect(created.firstEntry.flyerCount, 30);
    verifyNever(() => standApi.updateStandEntry(any(), any()));
  });

  test('a Termin added and deleted again offline is never sent', () async {
    await cache.addStandEntry('4711', _newEntry(DateTime(2026, 11, 21, 10)), _serverStand());
    final queuedEntry = (await cache.getPoiAsStandDetail('4711')).entries.first;

    await cache.deleteStandEntry('4711', queuedEntry.id, await cache.getPoiAsStandDetail('4711'));

    expect(await cache.getCachedActionCount(), 0);
  });

  test('deleting a Termin from the API replaces a queued change of it', () async {
    await cache.updateStandEntry(
      '4711',
      StandEntryUpdateModel(entryId: '1', startAt: DateTime(2026, 11, 7, 10), endAt: DateTime(2026, 11, 7, 12)),
      _serverStand(),
    );
    await cache.deleteStandEntry('4711', '1', _serverStand());

    await cache.flushCache();

    verify(() => standApi.deleteStandEntry('4711', '1')).called(1);
    verifyNever(() => standApi.updateStandEntry(any(), any()));
  });

  test('the detail shows queued Termin changes and keeps the flyer total from the API', () async {
    await cache.addStandEntry('4711', _newEntry(DateTime(2026, 11, 21, 10), flyerCount: 50), _serverStand());
    await cache.updateStandEntry(
      '4711',
      StandEntryUpdateModel(
        entryId: '1',
        startAt: DateTime(2026, 11, 7, 10),
        endAt: DateTime(2026, 11, 7, 12),
        flyerCount: 90,
      ),
      await cache.getPoiAsStandDetail('4711'),
    );
    await cache.deleteStandEntry('4711', '2', await cache.getPoiAsStandDetail('4711'));

    final stand = await cache.getPoiAsStandDetail('4711');

    expect(stand.flyerCountTotal, 250);
    expect(stand.entries.map((e) => e.flyerCount), [50, 90]); // newest first
    expect(stand.isCached, isTrue);
    expect(await cache.isCached('4711', PoiCacheType.stand), isTrue);
  });

  test('the only Termin of a stand created offline cannot be deleted', () async {
    final standId = await storeQueuedStand();
    final stand = await cache.getPoiAsStandDetail(standId);

    expect(() => cache.deleteStandEntry(standId, stand.entries.single.id, stand), throwsStateError);
  });

  test('deleting a stand created offline removes its Termine from the queue', () async {
    final standId = await storeQueuedStand();
    await cache.addStandEntry(standId, _newEntry(DateTime(2026, 11, 14, 10)), await cache.getPoiAsStandDetail(standId));

    await cache.deletePoi(PoiCacheType.stand, standId);

    expect(await cache.getCachedActionCount(), 0);
  });

  test('a Termin of a stand deleted on the server in the meantime is dropped', () async {
    when(() => standApi.addStandEntry(any(), any())).thenThrow(ApiException(statusCode: 404));
    await cache.addStandEntry('4711', _newEntry(DateTime(2026, 11, 21, 10)), _serverStand());

    await cache.flushCache();

    expect(await cache.getCachedActionCount(), 0);
  });

  test('the Termine of a stand that fails to sync stay in the queue', () async {
    when(() => standApi.createNewStand(any())).thenThrow(ApiException(statusCode: 500));
    final standId = await storeQueuedStand();
    await cache.addStandEntry(standId, _newEntry(DateTime(2026, 11, 14, 10)), await cache.getPoiAsStandDetail(standId));

    await cache.flushCache();

    verifyNever(() => standApi.addStandEntry(any(), any()));
    expect(await cache.getCachedActionCount(), 2);
    expect(cache.refusedActionCount, 0);
  });

  test('deleting the first Termin of a stand created offline makes the next queued Termin the first', () async {
    final standId = await storeQueuedStand();
    await cache.addStandEntry(
      standId,
      _newEntry(DateTime(2026, 11, 14, 10), flyerCount: 50),
      await cache.getPoiAsStandDetail(standId),
    );
    final stand = await cache.getPoiAsStandDetail(standId);
    final firstEntry = stand.entries.firstWhere((e) => e.flyerCount == 80);

    await cache.deleteStandEntry(standId, firstEntry.id, stand);

    final remaining = (await cache.getPoiAsStandDetail(standId)).entries.single;
    expect(remaining.flyerCount, 50);
    expect(remaining.startAt, DateTime(2026, 11, 14, 10));

    await cache.flushCache();

    final created = verify(() => standApi.createNewStand(captureAny())).captured.single as StandCreateModel;
    expect(created.firstEntry.flyerCount, 50);
    verifyNever(() => standApi.addStandEntry(any(), any()));
  });

  test('a photo added and deleted again offline is never uploaded', () async {
    when(() => standApi.updateStand(any()))
        .thenAnswer((_) async => PoiDetailModel(id: 4711, status: 'stand', location: _location));
    StandUpdateModel update({List<String> deletedPhotoIds = const [], List<PosterPhotoModel> newPhotos = const []}) =>
        StandUpdateModel(
          id: '4711',
          address: _address,
          location: _location,
          name: 'Marktplatz',
          oldStandDetail: _serverStand(),
          deletedPhotoIds: deletedPhotoIds,
          newPhotos: newPhotos,
        );
    final newPhoto = PosterPhotoModel(
      id: 'new-1',
      imageUrl: '/photos/a.jpg',
      thumbnailUrl: '/photos/a.jpg',
      createdAt: DateTime(2026, 11, 21),
    );

    await cache.updatePoi(PoiCacheType.stand, update(newPhotos: [newPhoto]));
    await cache.updatePoi(PoiCacheType.stand, update(deletedPhotoIds: ['new-1', 'p1']));
    await cache.flushCache();

    final sent = verify(() => standApi.updateStand(captureAny())).captured.single as StandUpdateModel;
    expect(sent.newPhotos, isEmpty);
    expect(sent.deletedPhotoIds, ['p1']);
  });

  test('a queued Termin deleted again does not show in a stand saved while it was queued', () async {
    await cache.addStandEntry('4711', _newEntry(DateTime(2026, 11, 21, 10)), _serverStand());
    final standWithQueuedEntry = await cache.getPoiAsStandDetail('4711');
    final queuedEntry = standWithQueuedEntry.entries.first;
    await cache.updatePoi(
      PoiCacheType.stand,
      StandUpdateModel(
        id: '4711',
        address: _address,
        location: _location,
        name: 'Wochenmarkt',
        oldStandDetail: standWithQueuedEntry,
      ),
    );

    await cache.deleteStandEntry('4711', queuedEntry.id, await cache.getPoiAsStandDetail('4711'));

    final stand = await cache.getPoiAsStandDetail('4711');
    expect(stand.name, 'Wochenmarkt');
    expect(stand.entries.map((e) => e.id), ['2', '1']);
  });

  test('changing and deleting a stand from the API is sent with its id', () async {
    when(() => standApi.updateStand(any()))
        .thenAnswer((_) async => PoiDetailModel(id: 4711, status: 'stand', location: _location));
    when(() => standApi.deletePoi(any())).thenAnswer((_) async {});

    await cache.updatePoi(
      PoiCacheType.stand,
      StandUpdateModel(
        id: '4711',
        address: _address,
        location: _location,
        name: 'Wochenmarkt',
        oldStandDetail: _serverStand(),
      ),
    );
    await cache.flushCache();
    await cache.deletePoi(PoiCacheType.stand, '4711');
    await cache.flushCache();

    final update = verify(() => standApi.updateStand(captureAny())).captured.single as StandUpdateModel;
    expect(update.id, '4711');
    verify(() => standApi.deletePoi('4711')).called(1);
    expect(await cache.getCachedActionCount(), 0);
  });

  test('two changes of the same Termin from the API are sent once, with the latest values', () async {
    StandEntryUpdateModel change(int flyerCount) => StandEntryUpdateModel(
      entryId: '1',
      startAt: DateTime(2026, 11, 7, 10),
      endAt: DateTime(2026, 11, 7, 12),
      flyerCount: flyerCount,
    );

    await cache.updateStandEntry('4711', change(90), _serverStand());
    await cache.updateStandEntry('4711', change(95), await cache.getPoiAsStandDetail('4711'));
    expect(await cache.getCachedActionCount(), 1);

    await cache.flushCache();

    final sent = verify(() => standApi.updateStandEntry('4711', captureAny())).captured.single as StandEntryUpdateModel;
    expect(sent.flyerCount, 95);
  });

  test('a stand from the API with only Termin changes shows on the map where it was last seen', () async {
    await cache.addStandEntry('4711', _newEntry(DateTime(2026, 11, 21, 10)), _serverStand());

    final marker = (await cache.getLayerItems(PoiCacheType.stand)).single;

    expect(marker.id.toString(), '4711');
    expect(marker.properties!.values, contains('stand'));
    final point = marker.geometry! as turf.Point;
    expect(point.coordinates.lat, _location.latitude);
    expect(point.coordinates.lng, _location.longitude);
  });

  group('actions the API refuses for good', () {
    test('a refused Termin is dropped and reported', () async {
      when(() => standApi.addStandEntry(any(), any())).thenThrow(ApiException(statusCode: 400));
      await cache.addStandEntry('4711', _newEntry(DateTime(2026, 11, 21, 10), flyerCount: 5), _serverStand());

      await cache.flushCache();

      expect(await cache.getCachedActionCount(), 0);
      expect(cache.refusedActionCount, 1);
    });

    test('a refused stand is dropped with its changes and Termine', () async {
      when(() => standApi.createNewStand(any())).thenThrow(ApiException(statusCode: 409));
      final standId = await storeQueuedStand();
      await cache.addStandEntry(
        standId,
        _newEntry(DateTime(2026, 11, 14, 10)),
        await cache.getPoiAsStandDetail(standId),
      );

      await cache.flushCache();

      verifyNever(() => standApi.addStandEntry(any(), any()));
      expect(await cache.getCachedActionCount(), 0);
      expect(cache.refusedActionCount, 2);
    });

    test('a change of a stand without write access is dropped and reported', () async {
      when(() => standApi.updateStand(any())).thenThrow(ApiException(statusCode: 403));
      await cache.updatePoi(
        PoiCacheType.stand,
        StandUpdateModel(
          id: '4711',
          address: _address,
          location: _location,
          name: 'Wochenmarkt',
          oldStandDetail: _serverStand(),
        ),
      );

      await cache.flushCache();

      expect(await cache.getCachedActionCount(), 0);
      expect(cache.refusedActionCount, 1);
    });

    test('reporting resets the count', () async {
      when(() => standApi.deleteStandEntry(any(), any())).thenThrow(ApiException(statusCode: 400));
      await cache.deleteStandEntry('4711', '1', _serverStand());
      await cache.flushCache();

      expect(cache.takeRefusedActionCount(), 1);
      expect(cache.refusedActionCount, 0);
    });

    test('poster actions are still retried, as before', () async {
      final posterApi = GetIt.I<PosterApiService>();
      when(() => posterApi.createNewPoster(any())).thenThrow(ApiException(statusCode: 400));
      await cache.storeNewPoi(
        PoiCacheType.poster,
        PosterCreateModel(address: _address, location: _location, campaignId: 'campaign-1'),
      );

      await cache.flushCache();

      expect(await cache.getCachedActionCount(), 1);
      expect(cache.refusedActionCount, 0);
    });
  });
}
