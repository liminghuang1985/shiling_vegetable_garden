import 'package:sqflite/sqflite.dart';
import '../../core/constants/db_constants.dart';
import '../../core/constants/enums.dart';
import '../models/city_model.dart';
import 'database_helper.dart';

/// 城市本地数据源
class CityLocalDatasource {
  final DatabaseHelper _dbHelper;

  CityLocalDatasource(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  /// 获取所有城市
  Future<List<CityModel>> getAllCities() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.cities,
      orderBy: 'province ASC, name ASC',
    );
    return maps.map((map) => CityModel.fromMap(map)).toList();
  }

  /// 按气候带获取城市
  Future<List<CityModel>> getCitiesByClimate(ClimateZone climate) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.cities,
      where: 'climate_zone = ?',
      whereArgs: [climate.name],
      orderBy: 'name ASC',
    );
    return maps.map((map) => CityModel.fromMap(map)).toList();
  }

  /// 搜索城市
  Future<List<CityModel>> searchCities(String query) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.cities,
      where: 'name LIKE ? OR province LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
      limit: 20,
    );
    return maps.map((map) => CityModel.fromMap(map)).toList();
  }

  /// 获取城市详情
  Future<CityModel?> getCityById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.cities,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CityModel.fromMap(maps.first);
  }

  /// 保存城市列表（批量插入）
  Future<void> saveCities(List<CityModel> cities) async {
    final db = await _db;
    final Batch batch = db.batch();

    for (final city in cities) {
      batch.insert(
        DbTables.cities,
        city.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// 插入单个城市
  Future<int> insertCity(CityModel city) async {
    final db = await _db;
    return await db.insert(
      DbTables.cities,
      city.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除所有城市
  Future<void> deleteAllCities() async {
    final db = await _db;
    await db.delete(DbTables.cities);
  }
}
