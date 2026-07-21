import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../../core/constants/enums.dart';
import '../models/garden_model.dart';
import 'database_helper.dart';

/// 用户菜园本地数据源
class GardenLocalDatasource {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid = const Uuid();

  GardenLocalDatasource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  /// 获取用户所有菜园蔬菜
  /// N+1 优化: 一次性拿全部 logs/reminders, group by garden_id, 避免 N*2 次循环查询
  Future<List<GardenVegetableModel>> getAllGardenVegetables() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.myGarden,
      orderBy: 'created_at DESC',
    );

    return _attachLogsAndRemindersBatch(maps);
  }

  /// 获取指定状态的菜园蔬菜
  Future<List<GardenVegetableModel>> getGardenVegetablesByStatus(GardenStatus status) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.myGarden,
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'created_at DESC',
    );

    return _attachLogsAndRemindersBatch(maps);
  }

  /// 获取菜园蔬菜详情
  Future<GardenVegetableModel?> getGardenVegetableById(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.myGarden,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    final results = await _attachLogsAndRemindersBatch(maps);
    return results.first;
  }

  /// 把 my_garden 行批量附加日志和提醒 (1+2 次 query, 不论 N 多大)
  Future<List<GardenVegetableModel>> _attachLogsAndRemindersBatch(
    List<Map<String, dynamic>> gardenMaps,
  ) async {
    if (gardenMaps.isEmpty) return [];
    final db = await _db;

    final gardenIds = gardenMaps.map((m) => m['id'] as String).toList();
    // 用占位符 '?, ?, ?' 避免 SQL 注入
    final placeholders = List.filled(gardenIds.length, '?').join(',');

    final logMaps = await db.query(
      DbTables.gardenLogs,
      where: 'garden_id IN ($placeholders)',
      whereArgs: gardenIds,
      orderBy: 'date DESC',
    );
    final reminderMaps = await db.query(
      DbTables.reminders,
      where: 'garden_id IN ($placeholders)',
      whereArgs: gardenIds,
      orderBy: 'time ASC',
    );

    // group by garden_id
    final logsByGarden = <String, List<GardenLogModel>>{};
    for (final m in logMaps) {
      final log = GardenLogModel.fromMap(m);
      logsByGarden.putIfAbsent(log.gardenId, () => []).add(log);
    }
    final remindersByGarden = <String, List<ReminderModel>>{};
    for (final m in reminderMaps) {
      final r = ReminderModel.fromMap(m);
      remindersByGarden.putIfAbsent(r.gardenId, () => []).add(r);
    }

    return gardenMaps.map((map) {
      final model = GardenVegetableModel.fromMap(map);
      return model.copyWithLogsAndReminders(
        logs: logsByGarden[model.id] ?? const [],
        reminders: remindersByGarden[model.id] ?? const [],
      );
    }).toList();
  }

  /// 添加蔬菜到菜园
  Future<GardenVegetableModel> addVegetableToGarden({
    required String vegetableId,
    required String vegetableName,
    required DateTime sowDate,
    BalconyDirection? sunlight,
  }) async {
    final db = await _db;
    final now = DateTime.now();
    final id = _uuid.v4();

    final model = GardenVegetableModel(
      id: id,
      vegetableId: vegetableId,
      vegetableName: vegetableName,
      sowDate: sowDate,
      sunlight: sunlight,
      status: GardenStatus.growing,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      DbTables.myGarden,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return model;
  }

  /// 更新菜园蔬菜状态
  Future<void> updateGardenVegetableStatus(String id, GardenStatus status) async {
    final db = await _db;
    await db.update(
      DbTables.myGarden,
      {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除菜园蔬菜
  Future<void> deleteGardenVegetable(String id) async {
    final db = await _db;
    // 日志和提醒会通过外键级联删除
    await db.delete(
      DbTables.myGarden,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ========== 生长日志相关 ==========

  /// 添加生长日志
  Future<GardenLogModel> addGardenLog({
    required String gardenId,
    required String note,
    String? photoPath,
  }) async {
    final db = await _db;
    final model = GardenLogModel(
      gardenId: gardenId,
      date: DateTime.now(),
      note: note,
      photoPath: photoPath,
    );

    final id = await db.insert(
      DbTables.gardenLogs,
      model.toMap(),
    );

    return GardenLogModel(
      id: id,
      gardenId: gardenId,
      date: model.date,
      note: note,
      photoPath: photoPath,
    );
  }

  /// 获取生长日志
  Future<List<GardenLogModel>> getGardenLogs(String gardenId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.gardenLogs,
      where: 'garden_id = ?',
      whereArgs: [gardenId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => GardenLogModel.fromMap(map)).toList();
  }

  /// 删除生长日志
  Future<void> deleteGardenLog(int id) async {
    final db = await _db;
    await db.delete(
      DbTables.gardenLogs,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ========== 提醒相关 ==========

  /// 添加提醒
  Future<ReminderModel> addReminder({
    required String gardenId,
    required ReminderType type,
    required DateTime time,
  }) async {
    final db = await _db;
    final model = ReminderModel(
      id: _uuid.v4(),
      gardenId: gardenId,
      type: type,
      time: time,
      isDone: false,
      createdAt: DateTime.now(),
    );

    await db.insert(
      DbTables.reminders,
      model.toMap(),
    );

    return model;
  }

  /// 获取提醒列表
  Future<List<ReminderModel>> getReminders(String gardenId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.reminders,
      where: 'garden_id = ?',
      whereArgs: [gardenId],
      orderBy: 'time ASC',
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// 获取所有未完成的提醒
  Future<List<ReminderModel>> getPendingReminders() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.reminders,
      where: 'is_done = 0',
      orderBy: 'time ASC',
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// 获取过期的提醒
  Future<List<ReminderModel>> getOverdueReminders() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.reminders,
      where: 'is_done = 0 AND time < ?',
      whereArgs: [now],
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// 更新提醒状态
  Future<void> updateReminderStatus(String reminderId, bool isDone) async {
    final db = await _db;
    await db.update(
      DbTables.reminders,
      {'is_done': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  /// 删除提醒
  Future<void> deleteReminder(String reminderId) async {
    final db = await _db;
    await db.delete(
      DbTables.reminders,
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  /// 标记所有过期提醒为已完成
  Future<void> markOverdueRemindersAsDone() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.update(
      DbTables.reminders,
      {'is_done': 1},
      where: 'is_done = 0 AND time < ?',
      whereArgs: [now],
    );
  }
}
