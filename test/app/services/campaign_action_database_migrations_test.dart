import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gruene_app/app/models/campaigns/campaign_action.dart';
import 'package:gruene_app/app/models/campaigns/doors/door_create_model.dart';
import 'package:gruene_app/app/services/campaign_action_database.dart';
import 'package:gruene_app/app/services/campaign_action_database_migrations.dart';
import 'package:gruene_app/app/services/nominatim/nominatim_service.dart';
import 'package:gruene_app/features/campaigns/core/cache/converters.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Schema as created by app versions with database version 1. Kept as a literal on purpose:
/// the upgrade must work on what is on devices, not on whatever the current schema is.
Future<void> _createV1Schema(Database db, int version) => db.execute('''
  CREATE TABLE campaign_action (
    _id INTEGER PRIMARY KEY AUTOINCREMENT,
    poiId INTEGER,
    poiTempId INTEGER NOT NULL,
    actionType INTEGER NOT NULL,
    serialized TEXT
  )
''');

// Action type values as stored in version 1 (see CampaignAction._ensureStableEnumValues)
const _addPoster = 1;
const _addDoor = 4;
const _editDoor = 5;
const _deleteDoor = 6;

// Payloads exactly as serialized by the previous app version
const _v1AddDoor =
    '{"location":[52.52,13.405],"address":{"street":"Hauptstraße","city":"Berlin","zipCode":"10115","houseNumber":"1"},'
    '"openedDoors":3,"closedDoors":2,"campaignId":"campaign-1"}';
const _v1EditDoor =
    '{"openedDoors":4,"closedDoors":0,"id":"4711",'
    '"address":{"street":"Nebenstraße","city":"Berlin","zipCode":"10115","houseNumber":"2"},'
    '"location":[52.53,13.41],'
    '"oldDoorDetail":{"id":"4711","address":{"street":"Nebenstraße","city":"Berlin","zipCode":"10115","houseNumber":"2"},'
    '"openedDoors":1,"closedDoors":5,"createdAt":"01.11.2026 10:00","location":[52.53,13.41],"isCached":false}}';
const _v1AddPoster =
    '{"location":[52.5,13.4],"address":{"street":"","city":"","zipCode":"","houseNumber":""},"campaignId":"campaign-1"}';

void main() {
  late Directory tempDir;
  late String path;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('campaign_action_db_test');
    path = join(tempDir.path, 'campaign_action_db.db');
  });

  tearDown(() => tempDir.delete(recursive: true));

  Future<void> seedV1Database(List<Map<String, Object?>> rows) async {
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createV1Schema),
    );
    for (final row in rows) {
      await db.insert('campaign_action', row);
    }
    await db.close();
  }

  Future<Database> openWithAppOptions() =>
      databaseFactoryFfi.openDatabase(path, options: CampaignActionDatabase.openOptions);

  Future<List<CampaignAction>> readActions(Database db) async => (await db.query(
    CampaignActionFields.tableName,
    orderBy: CampaignActionFields.id,
  )).map(CampaignAction.fromMap).toList();

  group('upgrade from version 1', () {
    test('converts queued door actions to the new count fields', () async {
      await seedV1Database([
        {'poiTempId': 1000, 'actionType': _addDoor, 'serialized': _v1AddDoor},
        {'poiId': 4711, 'poiTempId': 1001, 'actionType': _editDoor, 'serialized': _v1EditDoor},
      ]);

      final db = await openWithAppOptions();
      final actions = await readActions(db);
      await db.close();

      final created = actions[0].toDoorCreate();
      expect(created.conversations, 3);
      expect(created.materialOnly, 2);
      expect(created.campaignId, 'campaign-1');
      expect(created.address.street, 'Hauptstraße');
      expect(created.location.latitude, 52.52);

      final updated = actions[1].toDoorUpdate();
      expect(updated.id, '4711');
      expect(updated.conversations, 4);
      expect(updated.materialOnly, 0);
      expect(updated.oldDoorDetail.conversations, 1);
      expect(updated.oldDoorDetail.materialOnly, 5);
      expect(updated.oldDoorDetail.createdAt, '01.11.2026 10:00');
    });

    test('leaves other actions untouched', () async {
      await seedV1Database([
        {'poiId': 4712, 'poiTempId': 1002, 'actionType': _deleteDoor, 'serialized': null},
        {'poiTempId': 1003, 'actionType': _addPoster, 'serialized': _v1AddPoster},
      ]);

      final db = await openWithAppOptions();
      final rows = await db.query(CampaignActionFields.tableName, orderBy: CampaignActionFields.id);
      await db.close();

      expect(rows[0], {'_id': 1, 'poiId': 4712, 'poiTempId': 1002, 'actionType': _deleteDoor, 'serialized': null});
      expect(rows[1]['serialized'], _v1AddPoster);
    });

    test('runs only once', () async {
      await seedV1Database([
        {'poiTempId': 1000, 'actionType': _addDoor, 'serialized': _v1AddDoor},
      ]);

      await (await openWithAppOptions()).close();
      final db = await openWithAppOptions();
      final version = await db.getVersion();
      final actions = await readActions(db);
      await db.close();

      expect(version, CampaignActionDatabaseMigrations.currentVersion);
      expect(actions.single.toDoorCreate().conversations, 3);
    });
  });

  test('fresh install creates the current version and round-trips door actions', () async {
    final door = DoorCreateModel(
      location: LatLng(52.52, 13.405),
      address: AddressModel(street: 'Hauptstraße', houseNumber: '1', zipCode: '10115', city: 'Berlin'),
      conversations: 2,
      materialOnly: 7,
      campaignId: 'campaign-1',
    );

    final db = await openWithAppOptions();
    await db.insert(
      CampaignActionFields.tableName,
      CampaignAction(actionType: CampaignActionType.addDoor, serialized: jsonEncode(door.toJson())).toMap(),
    );
    final version = await db.getVersion();
    final actions = await readActions(db);
    await db.close();

    expect(version, CampaignActionDatabaseMigrations.currentVersion);
    final restored = actions.single.toDoorCreate();
    expect(restored.conversations, 2);
    expect(restored.materialOnly, 7);
    expect(restored.address.houseNumber, '1');
  });

  group('convertDoorCountFields', () {
    test('keeps payloads that already use the new fields', () {
      const payload = '{"conversations":1,"materialOnly":0,"campaignId":"c"}';
      expect(jsonDecode(CampaignActionDatabaseMigrations.convertDoorCountFields(payload)), jsonDecode(payload));
    });
  });
}
