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
  static final List<CampaignActionMigration> _steps = [_migrateDoorCountFields];

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
}
