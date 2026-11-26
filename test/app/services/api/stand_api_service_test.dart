import 'dart:io';
import 'dart:typed_data';

import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gruene_app/app/models/campaigns/posters/poster_photo_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_detail_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_create_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_entry_update_model.dart';
import 'package:gruene_app/app/models/campaigns/stands/stand_update_model.dart';
import 'package:gruene_app/app/services/api/base_api_service.dart';
import 'package:gruene_app/app/services/api/stand_api_service.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/app/utils/file_cache_manager.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';

class _MockGrueneApi extends Mock implements GrueneApi {}

class _MockFileManager extends Mock implements FileManager {}

final _address = AddressModel(street: 'Hauptstraße', houseNumber: '1', zipCode: '10115', city: 'Berlin');

PoiStandEntry _entry(String id, DateTime startAt, double flyerCount) => PoiStandEntry(
  id: id,
  startAt: startAt,
  endAt: startAt.add(const Duration(hours: 2)),
  flyerCount: flyerCount,
  userId: 'user-1',
  updatedBy: 'user-1',
  createdAt: startAt,
  updatedAt: startAt,
);

/// A stand as returned by the API. The flyer total deliberately differs from the sum of the entries,
/// to show that the app takes it from the API.
Poi _stand({List<ImageSrcSet> photos = const []}) => Poi(
  coords: [13.405, 52.52],
  type: PoiType.stand,
  id: '4711',
  campaignId: 'campaign-1',
  userId: 'user-1',
  divisionKey: '11000000',
  createdAt: DateTime.utc(2026, 11, 1, 9),
  updatedAt: DateTime.utc(2026, 11, 1, 9),
  photos: photos,
  address: const PoiAddress(street: 'Hauptstraße', houseNumber: '1', zip: '10115', city: 'Berlin'),
  stand: PoiStandDetails(
    name: 'Marktplatz',
    description: 'Vor dem Rathaus',
    flyerCountTotal: 250,
    entries: [_entry('2', DateTime.utc(2026, 11, 14, 9), 120), _entry('1', DateTime.utc(2026, 11, 7, 9), 80)],
  ),
);

ImageSrcSet _photo(String id) => ImageSrcSet(
  id: id,
  original: Image(id: '$id-o', url: 'https://example.com/$id.jpg', mimetype: 'image/jpeg', width: 800, height: 600),
  srcset: [
    Image(
      id: '$id-t',
      type: 'thumbnail',
      url: 'https://example.com/$id-t.jpg',
      mimetype: 'image/jpeg',
      width: 150,
      height: 150,
    ),
  ],
);

chopper.Response<T> _ok<T>(T body, {int statusCode = 200}) => chopper.Response(http.Response('', statusCode), body);

chopper.Response<Poi> _failed(int statusCode) => chopper.Response(http.Response('', statusCode), null);

void main() {
  late _MockGrueneApi api;
  late _MockFileManager fileManager;
  late StandApiService service;

  setUpAll(() {
    registerFallbackValue(CreatePoi(type: PoiType.stand, coords: const [], address: const PoiAddress()));
    registerFallbackValue(const UpdatePoi(address: PoiAddress()));
    registerFallbackValue(CreatePoiStandEntry(startAt: DateTime(2026), endAt: DateTime(2026)));
    registerFallbackValue(UpdatePoiStandEntry(startAt: DateTime(2026), endAt: DateTime(2026)));
    registerFallbackValue(http.MultipartFile.fromBytes('image', const []));
  });

  setUp(() {
    api = _MockGrueneApi();
    fileManager = _MockFileManager();
    GetIt.I.registerSingleton<GrueneApi>(api);
    GetIt.I.registerSingleton<FileManager>(fileManager);
    when(() => fileManager.retrieveFileData(any())).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
    service = StandApiService();
  });

  tearDown(GetIt.I.reset);

  test('creates a stand with its first Termin in UTC, without uploading its photos', () async {
    when(() => api.v1CampaignsPoisPost(body: any(named: 'body')))
        .thenAnswer((_) async => _ok(_stand(), statusCode: 201));

    final startAt = DateTime(2026, 11, 21, 10);
    final stand = await service.createNewStand(
      StandCreateModel(
        location: LatLng(52.52, 13.405),
        address: _address,
        name: 'Marktplatz',
        description: 'Vor dem Rathaus',
        firstEntry: StandEntryCreateModel(startAt: startAt, endAt: startAt.add(const Duration(hours: 2))),
        imageFileLocations: ['/photos/a.jpg', '/photos/b.jpg'],
        campaignId: 'campaign-1',
      ),
    );

    final body = verify(() => api.v1CampaignsPoisPost(body: captureAny(named: 'body'))).captured.single as CreatePoi;
    expect(body.type, PoiType.stand);
    expect(body.campaignId, 'campaign-1');
    expect(body.stand!.name, 'Marktplatz');
    expect(body.stand!.description, 'Vor dem Rathaus');
    expect(body.stand!.firstEntry.startAt, startAt.toUtc());
    expect(body.stand!.firstEntry.startAt.isUtc, isTrue);
    expect(body.stand!.firstEntry.flyerCount, isNull);

    // the offline queue uploads the photos as a change of the created stand
    verifyNever(
      () => api.v1CampaignsPoisPoiIdPhotosPost(
        poiId: any(named: 'poiId'),
        image: any(named: 'image'),
      ),
    );
    verifyNever(() => fileManager.deleteFile(any()));

    expect(stand.id, '4711');
    expect(stand.entries.map((e) => e.id), ['2', '1']);
  });

  test('reads a stand with its Termine and the flyer total from the API', () async {
    when(() => api.v1CampaignsPoisPoiIdGet(poiId: '4711')).thenAnswer((_) async => _ok(_stand(photos: [_photo('p1')])));

    final stand = await service.getPoiAsStandDetail('4711');

    expect(stand.name, 'Marktplatz');
    expect(stand.description, 'Vor dem Rathaus');
    expect(stand.comment, isNull);
    expect(stand.flyerCountTotal, 250);
    expect(stand.entries.map((e) => e.id), ['2', '1']);
    expect(stand.entries.first.flyerCount, 120);
    expect(stand.entries.first.startAt, DateTime.utc(2026, 11, 14, 9).toLocal());
    expect(stand.entries.first.startAt.isUtc, isFalse);
    expect(stand.photos.single.thumbnailUrl, 'https://example.com/p1-t.jpg');
    expect(stand.address.street, 'Hauptstraße');
  });

  test('changes the stand and its photos', () async {
    when(
      () => api.v1CampaignsPoisPoiIdPut(
        poiId: any(named: 'poiId'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => _ok(_stand()));
    when(() => api.v1CampaignsPoisPoiIdPhotosPhotoIdDelete(poiId: '4711', photoId: 'p1'))
        .thenAnswer((_) async => _ok(_stand()));
    when(
      () => api.v1CampaignsPoisPoiIdPhotosPost(
        poiId: any(named: 'poiId'),
        image: any(named: 'image'),
      ),
    ).thenAnswer((_) async => _ok(_stand(photos: [_photo('p2')]), statusCode: 201));

    await service.updateStand(
      StandUpdateModel(
        id: '4711',
        address: _address,
        location: LatLng(52.52, 13.405),
        name: 'Wochenmarkt',
        comment: 'Neuer Name',
        oldStandDetail: StandDetailModel(
          id: '4711',
          address: _address,
          location: LatLng(52.52, 13.405),
          name: 'Marktplatz',
          flyerCountTotal: 250,
          entries: const [],
          photos: const [],
          createdAt: '01.11.2026 10:00',
        ),
        deletedPhotoIds: ['p1'],
        newPhotos: [
          PosterPhotoModel(id: 'new', imageUrl: '/photos/c.jpg', thumbnailUrl: '', createdAt: DateTime(2026)),
        ],
      ),
    );

    final body =
        verify(
              () => api.v1CampaignsPoisPoiIdPut(
                poiId: '4711',
                body: captureAny(named: 'body'),
              ),
            ).captured.single
            as UpdatePoi;
    expect(body.stand!.name, 'Wochenmarkt');
    expect(body.stand!.comment, 'Neuer Name');
    verify(() => api.v1CampaignsPoisPoiIdPhotosPhotoIdDelete(poiId: '4711', photoId: 'p1')).called(1);
    verify(() => fileManager.deleteFile('/photos/c.jpg')).called(1);
  });

  test('a retried change skips a photo whose file was deleted by an earlier upload', () async {
    when(
      () => api.v1CampaignsPoisPoiIdPut(
        poiId: any(named: 'poiId'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => _ok(_stand()));
    when(
      () => api.v1CampaignsPoisPoiIdPhotosPost(
        poiId: any(named: 'poiId'),
        image: any(named: 'image'),
      ),
    ).thenAnswer((_) async => _ok(_stand(photos: [_photo('p2')]), statusCode: 201));
    when(() => fileManager.retrieveFileData('/photos/a.jpg'))
        .thenThrow(const PathNotFoundException('/photos/a.jpg', OSError()));
    PosterPhotoModel photo(String file) =>
        PosterPhotoModel(id: file, imageUrl: file, thumbnailUrl: file, createdAt: DateTime(2026));

    await service.updateStand(
      StandUpdateModel(
        id: '4711',
        address: _address,
        location: LatLng(52.52, 13.405),
        name: 'Marktplatz',
        oldStandDetail: StandDetailModel(
          id: '4711',
          address: _address,
          location: LatLng(52.52, 13.405),
          name: 'Marktplatz',
          flyerCountTotal: 250,
          entries: const [],
          photos: const [],
          createdAt: '01.11.2026 10:00',
        ),
        newPhotos: [photo('/photos/a.jpg'), photo('/photos/b.jpg')],
      ),
    );

    verify(
      () => api.v1CampaignsPoisPoiIdPhotosPost(
        poiId: '4711',
        image: any(named: 'image'),
      ),
    ).called(1);
    verify(() => fileManager.deleteFile('/photos/b.jpg')).called(1);
  });

  group('Termine', () {
    test('adding one returns the stand with the flyer total from the API', () async {
      when(
        () => api.v1CampaignsPoisPoiIdEntriesPost(
          poiId: any(named: 'poiId'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => _ok(_stand(), statusCode: 201));

      final startAt = DateTime(2026, 11, 14, 10);
      final stand = await service.addStandEntry(
        '4711',
        StandEntryCreateModel(startAt: startAt, endAt: startAt.add(const Duration(hours: 2)), flyerCount: 120),
      );

      final body =
          verify(
                () => api.v1CampaignsPoisPoiIdEntriesPost(
                  poiId: '4711',
                  body: captureAny(named: 'body'),
                ),
              ).captured.single
              as CreatePoiStandEntry;
      expect(body.startAt, startAt.toUtc());
      expect(body.flyerCount, 120);
      expect(stand.flyerCountTotal, 250);
    });

    test('changing one sends it to its own endpoint', () async {
      when(
        () => api.v1CampaignsPoisPoiIdEntriesEntryIdPut(
          poiId: any(named: 'poiId'),
          entryId: any(named: 'entryId'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => _ok(_stand()));

      final startAt = DateTime(2026, 11, 7, 10);
      await service.updateStandEntry(
        '4711',
        StandEntryUpdateModel(
          entryId: '1',
          startAt: startAt,
          endAt: startAt.add(const Duration(hours: 3)),
          flyerCount: 90,
        ),
      );

      final body =
          verify(
                () => api.v1CampaignsPoisPoiIdEntriesEntryIdPut(
                  poiId: '4711',
                  entryId: '1',
                  body: captureAny(named: 'body'),
                ),
              ).captured.single
              as UpdatePoiStandEntry;
      expect(body.endAt, startAt.add(const Duration(hours: 3)).toUtc());
      expect(body.flyerCount, 90);
    });

    test('deleting one returns the remaining Termine', () async {
      when(() => api.v1CampaignsPoisPoiIdEntriesEntryIdDelete(poiId: '4711', entryId: '2'))
          .thenAnswer((_) async => _ok(_stand()));

      final stand = await service.deleteStandEntry('4711', '2');

      expect(stand.entries, isNotEmpty);
    });

    test('a refused action throws with its status code', () async {
      when(() => api.v1CampaignsPoisPoiIdEntriesEntryIdDelete(poiId: '4711', entryId: '2'))
          .thenAnswer((_) async => _failed(409));

      expect(
        () => service.deleteStandEntry('4711', '2'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409)),
      );
    });
  });

  group('map pins', () {
    tearDown(() => dotenv.clean());

    test('loads stands of the campaign as one stand pin each, ignoring POI_FILTER_DATE', () async {
      // the stand was created on 01.11.2026, before the cut-off date
      dotenv.loadFromString(envString: 'POI_FILTER_DATE=15.11.2026');
      when(
        () => api.v1CampaignsPoisGet(
          type: any(named: 'type'),
          bbox: any(named: 'bbox'),
          campaignId: any(named: 'campaignId'),
        ),
      ).thenAnswer((_) async => _ok(FindPoisResponse(data: [_stand()], total: 1, offset: 0, limit: 100)));

      final markers = await service.loadPoisInRegion('campaign-1', LatLng(52.5, 13.4), LatLng(52.6, 13.5));

      expect(markers, hasLength(1));
      expect(markers.single.id, 4711);
      expect(markers.single.status, 'stand');
      verify(
        () => api.v1CampaignsPoisGet(
          type: PoiType.stand,
          bbox: any(named: 'bbox'),
          campaignId: ['campaign-1'],
        ),
      ).called(1);
    });
  });
}
