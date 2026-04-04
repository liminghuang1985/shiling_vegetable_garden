import '../core/constants/app_constants.dart';
import '../core/constants/enums.dart';
import 'datasources/database_helper.dart';
import 'models/city_model.dart';

/// 应用数据初始化器
/// 在首次启动时将预设数据写入数据库
class DataSeeder {
  final DatabaseHelper _dbHelper;

  DataSeeder(this._dbHelper);

  /// 初始化所有预设数据
  Future<void> seedIfNeeded() async {
    final isEmpty = await _dbHelper.isDatabaseEmpty();
    if (isEmpty) {
      await _seedCities();
    }
  }

  /// 播种预设城市数据
  Future<void> _seedCities() async {
    final cities = AppConstants.presetCities.map((json) {
      return CityModel(
        name: json['name'] as String,
        province: json['province'] as String,
        climate: ClimateZone.fromString(json['climate_zone'] as String) ?? ClimateZone.warmTemperate,
      );
    }).toList();

    await _dbHelper.database.then((db) async {
      for (final city in cities) {
        await db.insert(
          'cities',
          city.toMap(),
        );
      }
    });
  }
}
