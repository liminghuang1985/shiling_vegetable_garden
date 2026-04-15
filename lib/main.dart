import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/constants/enums.dart';
import 'data/models/city_model.dart';
import 'domain/entities/city.dart';
import 'presentation/providers/providers.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化数据库
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database;

    // 初始化预设数据
    final seeder = DataSeeder(dbHelper);
    await seeder.seedIfNeeded();

    // 恢复用户设置
    final settings = SettingsLocalDatasource();
    final savedClimate = await settings.getSelectedClimate();
    final savedDirection = await settings.getBalconyDirection();
    final savedCityId = await settings.getSelectedCityId();

    // 恢复保存的城市
    City? savedCity;
    if (savedCityId != null && savedCityId > 0) {
      try {
        final db = await dbHelper.database;
        final maps = await db.query('cities', where: 'id = ?', whereArgs: [savedCityId], limit: 1);
        if (maps.isNotEmpty) {
          savedCity = CityModel.fromMap(maps.first);
        }
      } catch (_) {
        // 忽略城市加载错误
      }
    }

    // 构建 Provider 覆盖
    final climateOverride = savedClimate != null
        ? selectedClimateZoneProvider.overrideWith(
            (ref) => ClimateZone.fromString(savedClimate) ?? ClimateZone.warmTemperate,
          )
        : null;

    final directionOverride = savedDirection != null
        ? balconyDirectionProvider.overrideWith(
            (ref) => BalconyDirection.values.firstWhere(
              (d) => d.name == savedDirection,
              orElse: () => BalconyDirection.south,
            ),
          )
        : null;

    // 城市恢复：如果有保存的城市，用它覆盖 selectedCityProvider
    final cityOverride = savedCity != null
        ? selectedCityProvider.overrideWith((ref) => savedCity)
        : null;

    runApp(
      ProviderScope(
        overrides: [
          if (climateOverride != null) climateOverride,
          if (directionOverride != null) directionOverride,
          if (cityOverride != null) cityOverride,
        ],
        child: const ShilingVegetableGardenApp(),
      ),
    );
  } catch (e, st) {
    debugPrint('=== APP INIT ERROR: $e ===');
    debugPrint('=== STACK: $st ===');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('初始化失败:\n$e', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('堆栈:\n$st', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
