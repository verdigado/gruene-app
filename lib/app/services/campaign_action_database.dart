import 'package:gruene_app/features/campaigns/helper/campaign_action.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CampaignActionDatabase {
  static final CampaignActionDatabase instance = CampaignActionDatabase._internal();

  static Database? _database;

  CampaignActionDatabase._internal();

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'campaign_action_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, _) async {
    return await db.execute('''
        CREATE TABLE ${CampaignActionFields.tableName} (
          ${CampaignActionFields.id} ${CampaignActionFields.idType},
          ${CampaignActionFields.poiId} ${CampaignActionFields.intTypeNullable},
          ${CampaignActionFields.poiTempId} ${CampaignActionFields.intType},
          ${CampaignActionFields.actionType} ${CampaignActionFields.intType},
          ${CampaignActionFields.serialized} ${CampaignActionFields.textTypeNullable}
        )
      ''');
  }

  Future<CampaignAction> create(CampaignAction campaignAction) async {
    final db = await instance.database;
    final id = await db.insert(CampaignActionFields.tableName, campaignAction.toMap());
    return campaignAction.copyWith(id: id);
  }

  Future<List<CampaignAction>> readAll() async {
    final db = await instance.database;
    const orderBy = '${CampaignActionFields.poiTempId} ASC, ${CampaignActionFields.id} ASC';
    final result = await db.query(CampaignActionFields.tableName, orderBy: orderBy);
    return result.map((json) => CampaignAction.fromMap(json)).toList();
  }

  Future<List<CampaignAction>> readAllByActionType(List<int> posterActions) async {
    final db = await instance.database;
    const orderBy = '${CampaignActionFields.poiTempId} ASC, ${CampaignActionFields.id} ASC';
    final result = await db.query(
      CampaignActionFields.tableName,
      orderBy: orderBy,
      where: '${CampaignActionFields.actionType} IN (${List.filled(posterActions.length, '?').join(',')})',
      whereArgs: posterActions,
    );
    return result.map((json) => CampaignAction.fromMap(json)).toList();
  }

  Future<List<CampaignAction>> getActionsWithPoiId(String poiId) async {
    final db = await instance.database;
    const orderBy = '${CampaignActionFields.poiTempId} ASC, ${CampaignActionFields.id} ASC';
    final result = await db.query(
      CampaignActionFields.tableName,
      orderBy: orderBy,
      where: '${CampaignActionFields.poiId} = ? OR ${CampaignActionFields.poiTempId} = ?',
      whereArgs: [poiId, poiId],
    );
    return result.map((json) => CampaignAction.fromMap(json)).toList();
  }

  Future<void> update(CampaignAction campaignAction) async {
    final db = await instance.database;
    db.update(
      CampaignActionFields.tableName,
      campaignAction.toMap(),
      where: '${CampaignActionFields.id} = ?',
      whereArgs: [campaignAction.id],
    );
  }

  Future<void> updatePoiId(int oldId, int newId) async {
    final db = await instance.database;
    await db.update(
      CampaignActionFields.tableName,
      {CampaignActionFields.poiId: newId},
      where: '${CampaignActionFields.poiId} = ?',
      whereArgs: [oldId],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      CampaignActionFields.tableName,
      where: '${CampaignActionFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> getCount() async {
    final db = await instance.database;
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ${CampaignActionFields.tableName}')) ?? 0;
    return count;
  }

  Future<bool> actionsWithPoiIdExists(String poiId) async {
    final db = await instance.database;
    final result = await db.query(
      CampaignActionFields.tableName,
      columns: ['COUNT(*)'],
      where: '${CampaignActionFields.poiId} = ? OR ${CampaignActionFields.poiTempId} = ?',
      whereArgs: [poiId, poiId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}

class CampaignActionFields {
  static const String tableName = 'campaign_action';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textTypeNullable = 'TEXT';
  static const String intType = 'INTEGER NOT NULL';
  static const String intTypeNullable = 'INTEGER';
  static const String id = '_id';
  static const String poiId = 'poiId';
  static const String poiTempId = 'poiTempId';
  static const String actionType = 'actionType';
  static const String serialized = 'serialized';
}
