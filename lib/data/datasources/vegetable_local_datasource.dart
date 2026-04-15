import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../../core/constants/enums.dart';
import '../models/vegetable_model.dart';
import '../models/planting_calendar_model.dart';
import 'database_helper.dart';

/// 蔬菜本地数据源
class VegetableLocalDatasource {
  final DatabaseHelper _dbHelper;

  VegetableLocalDatasource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  /// 获取所有蔬菜
  Future<List<VegetableModel>> getAllVegetables() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.vegetables,
      orderBy: 'name ASC',
    );
    return maps.map((map) => VegetableModel.fromMap(map)).toList();
  }

  /// 按分类获取蔬菜
  Future<List<VegetableModel>> getVegetablesByCategory(VegetableCategory category) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.vegetables,
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'name ASC',
    );
    return maps.map((map) => VegetableModel.fromMap(map)).toList();
  }

  /// 按气候带获取适合的蔬菜
  Future<List<VegetableModel>> getVegetablesByClimate(ClimateZone climate) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.vegetables,
      where: 'suitable_climates LIKE ?',
      whereArgs: ['%${climate.name}%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => VegetableModel.fromMap(map)).toList();
  }

  /// 获取蔬菜详情
  Future<VegetableModel?> getVegetableById(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.vegetables,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return VegetableModel.fromMap(maps.first);
  }

  /// 搜索蔬菜
  Future<List<VegetableModel>> searchVegetables(String query) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.vegetables,
      where: 'name LIKE ? OR alias LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
      limit: 20,
    );
    return maps.map((map) => VegetableModel.fromMap(map)).toList();
  }

  /// 保存蔬菜列表（批量插入）
  Future<void> saveVegetables(List<VegetableModel> vegetables) async {
    final db = await _db;
    final Batch batch = db.batch();

    for (final veg in vegetables) {
      batch.insert(
        DbTables.vegetables,
        veg.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// 插入单个蔬菜
  Future<void> insertVegetable(VegetableModel vegetable) async {
    final db = await _db;
    await db.insert(
      DbTables.vegetables,
      vegetable.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除所有蔬菜
  Future<void> deleteAllVegetables() async {
    final db = await _db;
    await db.delete(DbTables.vegetables);
  }

  /// ========== 种植日历相关 ==========

  /// 获取种植日历
  Future<PlantingCalendarModel> getPlantingCalendar() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.plantingCalendar,
    );

    if (maps.isEmpty) {
      // 返回示例日历
      return PlantingCalendarModel.generateSampleCalendar();
    }

    return PlantingCalendarModel.fromDbRecords(maps);
  }

  /// 保存种植日历
  Future<void> savePlantingCalendar(PlantingCalendarModel calendar) async {
    final db = await _db;
    final records = calendar.toDbRecords();
    final Batch batch = db.batch();

    // 先清空旧数据
    batch.delete(DbTables.plantingCalendar);

    // 插入新数据
    for (final record in records) {
      batch.insert(DbTables.plantingCalendar, record);
    }

    await batch.commit(noResult: true);
  }

  /// 获取指定气候带和月份可种的蔬菜ID列表
  Future<List<String>> getVegetableIdsForClimateAndMonth(
    ClimateZone climate,
    int month,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.plantingCalendar,
      where: 'climate_zone = ? AND month = ?',
      whereArgs: [climate.name, month],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final vegIds = maps.first['vegetable_ids'] as String;
      if (vegIds.isNotEmpty) return vegIds.split(',');
    }

    // Fallback: 如果 DB 没有数据（可能是旧版本数据未迁移），使用内存中的示例数据
    final sampleCalendar = PlantingCalendarModel.generateSampleCalendar();
    final sampleData = sampleCalendar.data[climate];
    if (sampleData != null && sampleData.containsKey(month)) {
      return sampleData[month]!;
    }

    return [];
  }

  /// 批量获取蔬菜（用于避免 N+1 查询）
  Future<List<VegetableModel>> getVegetablesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.vegetables,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return maps.map((map) => VegetableModel.fromMap(map)).toList();
  }
}
