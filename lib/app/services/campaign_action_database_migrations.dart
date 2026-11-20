// The flyer action types are deprecated; converting them is what this file is for.
// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';

import 'package:gruene_app/app/models/campaigns/campaign_action.dart';
import 'package:gruene_app/app/services/campaign_action_database.dart';
import 'package:sqflite/sqflite.dart';

typedef CampaignActionMigration = Future<void> Function(DatabaseExecutor db);

/// One-time conversions of the offline queue, run by sqflite's `onUpgrade` before the first access.
///
/// The step at index `i` upgrades the database from version `i + 1` to `i + 2`.
/// New steps must only be appended, so devices on any older version run the missing ones in order.
class CampaignActionDatabaseMigrations {
  static final List<CampaignActionMigration> _steps = [_migrateDoorCountFields, _migrateFlyerActionsToDoors];

  static int get currentVersion => _steps.length + 1;

  static Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
    for (var version = oldVersion; version < newVersion; version++) {
      await _steps[version - 1](db);
    }
  }

  /// v1 → v2: door counts were renamed (`openedDoors` → `conversations`, `closedDoors` → `materialOnly`),
  /// following the API rename to `countConversations` / `countMaterialOnly` (gruene-api#742).
  static Future<void> _migrateDoorCountFields(DatabaseExecutor db) async {
    final doorActionTypes = [CampaignActionType.addDoor.index, CampaignActionType.editDoor.index];
    final rows = await db.query(
      CampaignActionFields.tableName,
      columns: [CampaignActionFields.id, CampaignActionFields.serialized],
      where: '${CampaignActionFields.actionType} IN (${List.filled(doorActionTypes.length, '?').join(',')})',
      whereArgs: doorActionTypes,
    );

    for (final row in rows) {
      final serialized = row[CampaignActionFields.serialized] as String?;
      if (serialized == null) continue;

      await db.update(
        CampaignActionFields.tableName,
        {CampaignActionFields.serialized: convertDoorCountFields(serialized)},
        where: '${CampaignActionFields.id} = ?',
        whereArgs: [row[CampaignActionFields.id]],
      );
    }
  }

  /// Renames the door count keys of a serialized `DoorCreateModel` or `DoorUpdateModel`,
  /// including the embedded `oldDoorDetail` of an update.
  static String convertDoorCountFields(String serialized) {
    final data = jsonDecode(serialized) as Map<String, dynamic>;
    _renameDoorCountKeys(data);
    final oldDoorDetail = data['oldDoorDetail'];
    if (oldDoorDetail is Map<String, dynamic>) _renameDoorCountKeys(oldDoorDetail);
    return jsonEncode(data);
  }

  static void _renameDoorCountKeys(Map<String, dynamic> data) {
    const renames = {'openedDoors': 'conversations', 'closedDoors': 'materialOnly'};
    for (final MapEntry(key: oldKey, value: newKey) in renames.entries) {
      if (data.containsKey(oldKey)) data[newKey] = data.remove(oldKey);
    }
  }

  /// v2 → v3: flyer pins no longer exist in the API (gruene-api#744), flyer pins on the server became door entries.
  /// Queued flyer actions are turned into door actions, the flyer count becomes "material only":
  /// - `addFlyer` → `addDoor`; an `editFlyer` of that queued pin is merged into it
  /// - `editFlyer` of a pin already on the server → `editDoor`
  /// - `deleteFlyer` → `deleteDoor` (the delete endpoint does not depend on the pin type)
  /// - `addFlyer` followed by `deleteFlyer` of the same pin → all actions of that pin are dropped
  static Future<void> _migrateFlyerActionsToDoors(DatabaseExecutor db) async {
    // Stored values of the flyer action types, see CampaignAction._ensureStableEnumValues
    final addFlyer = CampaignActionType.addFlyer.index;
    final editFlyer = CampaignActionType.editFlyer.index;
    final deleteFlyer = CampaignActionType.deleteFlyer.index;

    final rows = await db.query(
      CampaignActionFields.tableName,
      where: '${CampaignActionFields.actionType} IN (?, ?, ?)',
      whereArgs: [addFlyer, editFlyer, deleteFlyer],
      orderBy: CampaignActionFields.id,
    );

    int actionType(Map<String, Object?> row) => row[CampaignActionFields.actionType] as int;
    int? poiId(Map<String, Object?> row) => row[CampaignActionFields.poiId] as int?;
    int poiTempId(Map<String, Object?> row) => row[CampaignActionFields.poiTempId] as int;
    String? serialized(Map<String, Object?> row) => row[CampaignActionFields.serialized] as String?;

    Future<void> deleteRow(Map<String, Object?> row) => db.delete(
      CampaignActionFields.tableName,
      where: '${CampaignActionFields.id} = ?',
      whereArgs: [row[CampaignActionFields.id]],
    );

    Future<void> updateRow(Map<String, Object?> row, int newActionType, String? newSerialized) => db.update(
      CampaignActionFields.tableName,
      {CampaignActionFields.actionType: newActionType, CampaignActionFields.serialized: newSerialized},
      where: '${CampaignActionFields.id} = ?',
      whereArgs: [row[CampaignActionFields.id]],
    );

    // Actions on a pin that is still queued refer to it by the poiTempId of its add action
    final queuedPins = {for (final row in rows.where((r) => actionType(r) == addFlyer)) poiTempId(row): row};
    final deletedQueuedPins = rows
        .where((r) => actionType(r) == deleteFlyer && queuedPins.containsKey(poiId(r)))
        .map(poiId)
        .toSet();

    for (final row in rows) {
      final type = actionType(row);
      final pinId = type == addFlyer ? poiTempId(row) : poiId(row);

      if (deletedQueuedPins.contains(pinId)) {
        await deleteRow(row);
      } else if (type == addFlyer) {
        // edits of the queued pin are merged in insertion order, so the last edit wins
        var create = jsonDecode(serialized(row)!) as Map<String, dynamic>;
        for (final edit in rows.where((r) => actionType(r) == editFlyer && poiId(r) == pinId)) {
          create = mergeFlyerUpdateIntoCreate(create, jsonDecode(serialized(edit)!) as Map<String, dynamic>);
        }
        await updateRow(row, CampaignActionType.addDoor.index, jsonEncode(convertFlyerCreateToDoorCreate(create)));
      } else if (type == editFlyer) {
        if (queuedPins.containsKey(pinId)) {
          await deleteRow(row); // merged into the converted add action above
        } else {
          final update = jsonDecode(serialized(row)!) as Map<String, dynamic>;
          await updateRow(row, CampaignActionType.editDoor.index, jsonEncode(convertFlyerUpdateToDoorUpdate(update)));
        }
      } else if (type == deleteFlyer) {
        await updateRow(row, CampaignActionType.deleteDoor.index, serialized(row));
      }
    }
  }

  /// Applies the values of a serialized `FlyerUpdateModel` to a serialized `FlyerCreateModel`.
  static Map<String, dynamic> mergeFlyerUpdateIntoCreate(Map<String, dynamic> create, Map<String, dynamic> update) => {
    ...create,
    for (final key in const ['location', 'address', 'flyerCount'])
      if (update.containsKey(key)) key: update[key],
  };

  /// Serialized `FlyerCreateModel` → serialized `DoorCreateModel`.
  static Map<String, dynamic> convertFlyerCreateToDoorCreate(Map<String, dynamic> flyer) => {
    'location': flyer['location'],
    'address': flyer['address'],
    'conversations': 0,
    'materialOnly': flyer['flyerCount'] ?? 0,
    'campaignId': flyer['campaignId'],
  };

  /// Serialized `FlyerUpdateModel` → serialized `DoorUpdateModel`, including its `oldFlyerDetail`.
  static Map<String, dynamic> convertFlyerUpdateToDoorUpdate(Map<String, dynamic> flyer) {
    final oldDetail = flyer['oldFlyerDetail'] as Map<String, dynamic>;
    return {
      'id': flyer['id'],
      'address': flyer['address'],
      'location': flyer['location'],
      'conversations': 0,
      'materialOnly': flyer['flyerCount'] ?? 0,
      'oldDoorDetail': {
        'id': oldDetail['id'],
        'address': oldDetail['address'],
        'conversations': 0,
        'materialOnly': oldDetail['flyerCount'] ?? 0,
        'createdAt': oldDetail['createdAt'],
        'location': oldDetail['location'],
        'isCached': oldDetail['isCached'] ?? false,
      },
    };
  }
}
