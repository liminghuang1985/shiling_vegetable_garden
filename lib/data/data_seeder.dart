import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/constants/enums.dart';
import '../core/constants/db_constants.dart';
import '../core/constants/app_constants.dart';
import 'datasources/database_helper.dart';
import 'models/city_model.dart';
import 'models/vegetable_model.dart';

/// 应用数据初始化器
/// 在首次启动时将预设数据写入数据库
class DataSeeder {
  final DatabaseHelper _dbHelper;

  DataSeeder(this._dbHelper);

  /// 初始化所有预设数据
  Future<void> seedIfNeeded() async {
    try {
      final isEmpty = await _dbHelper.isDatabaseEmpty();
      if (isEmpty) {
        await _seedCities();
        await _seedVegetables();
        await _seedPlantingCalendar();
      }
    } catch (e) {
      // Continue anyway - don't crash the app
    }
  }

  /// 强制重新播种（清除所有数据后重新写入）
  static Future<void> forceReSeed() async {
    final seeder = DataSeeder(DatabaseHelper.instance);
    await seeder._clearAll();
    await seeder._seedCities();
    await seeder._seedVegetables();
    await seeder._seedPlantingCalendar();
  }

  Future<void> _clearAll() async {
    final db = await _dbHelper.database;
    await db.delete(DbTables.cities);
    await db.delete(DbTables.vegetables);
    await db.delete(DbTables.plantingCalendar);
    await db.delete(DbTables.myGarden);
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

    final db = await _dbHelper.database;
    for (final city in cities) {
      await db.insert(
        'cities',
        city.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// 播种蔬菜数据
  Future<void> _seedVegetables() async {
    // 从 assets 加载 JSON
    final jsonString = await rootBundle.loadString('assets/data/vegetables.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    final db = await _dbHelper.database;

    for (final item in jsonList) {
      final vegetable = VegetableModel.fromJson(item as Map<String, dynamic>);
      await db.insert(
        'vegetables',
        vegetable.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// 播种种植日历数据
  Future<void> _seedPlantingCalendar() async {
    // 从 assets 加载 JSON
    final jsonString = await rootBundle.loadString('assets/data/planting_calendar.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    final db = await _dbHelper.database;

    // 遍历每个气候区
    for (final climateEntry in jsonMap.entries) {
      final climate = ClimateZone.fromString(climateEntry.key);
      if (climate == null) continue;

      final monthData = climateEntry.value as Map<String, dynamic>;

      // 遍历每个月份
      for (final monthEntry in monthData.entries) {
        final month = int.tryParse(monthEntry.key);
        if (month == null) continue;

        final vegIds = (monthEntry.value as List<dynamic>).cast<String>();

        // 插入或更新
        await db.insert(
          'planting_calendar',
          {
            'climate_zone': climate.name,
            'month': month,
            'vegetable_ids': vegIds.join(','),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
}
