import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/vegetable.dart';
import '../../domain/entities/garden_vegetable.dart';

/// Hive 数据源 - 跨平台统一数据访问
class HiveDataSource {
  static const String vegetablesBox = 'vegetables';
  static const String citiesBox = 'cities';
  static const String gardenBox = 'my_garden';
  static const String calendarBox = 'planting_calendar';

  static bool _isBoxOpen(String name) {
    try {
      return Hive.box(name).isOpen;
    } catch (_) {
      return false;
    }
  }

  static Box _getBox(String name) {
    if (!_isBoxOpen(name)) {
      debugPrint('=== HiveDataSource: Box "$name" is not open ===');
      throw Exception('Hive box "$name" is not open');
    }
    return Hive.box(name);
  }

  static Future<void> openBoxes() async {
    debugPrint('=== HiveDataSource.openBoxes() starting ===');
    if (!Hive.isBoxOpen(vegetablesBox)) await Hive.openBox<Map>(vegetablesBox);
    if (!Hive.isBoxOpen(citiesBox)) await Hive.openBox<Map>(citiesBox);
    if (!Hive.isBoxOpen(gardenBox)) await Hive.openBox<Map>(gardenBox);
    if (!Hive.isBoxOpen(calendarBox)) await Hive.openBox<String>(calendarBox);
    debugPrint('=== HiveDataSource.openBoxes() done ===');
  }

  // ========== 城市操作 ==========
  static List<City> getAllCities() {
    try {
      return _getBox(citiesBox).values.map((map) => _cityFromMap(map)).toList();
    } catch (e) {
      debugPrint('=== getAllCities error: $e ===');
      return [];
    }
  }

  static List<City> getCitiesByClimate(ClimateZone climate) {
    try {
      return getAllCities().where((c) => c.climate == climate).toList();
    } catch (e) { debugPrint('=== getCitiesByClimate error: $e ==='); return []; }
  }

  static List<City> searchCities(String query) {
    try {
      return getAllCities().where((c) => c.name.contains(query) || c.province.contains(query)).toList();
    } catch (e) { debugPrint('=== searchCities error: $e ==='); return []; }
  }

  static Future<void> saveCities(List<City> cities) async {
    try {
      final box = _getBox(citiesBox);
      for (final city in cities) await box.put(city.name, _cityToMap(city));
    } catch (e) { debugPrint('=== saveCities error: $e ==='); }
  }

  // ========== 蔬菜操作 ==========
  static List<Vegetable> getAllVegetables() {
    try {
      return _getBox(vegetablesBox).values.map((map) => _vegetableFromMap(Map<String, dynamic>.from(map))).toList();
    } catch (e) { debugPrint('=== getAllVegetables error: $e ==='); return []; }
  }

  static List<Vegetable> getVegetablesByCategory(VegetableCategory category) {
    try {
      return getAllVegetables().where((v) => v.category == category).toList();
    } catch (e) { debugPrint('=== getVegetablesByCategory error: $e ==='); return []; }
  }

  static List<Vegetable> getVegetablesByClimate(ClimateZone climate) {
    try {
      return getAllVegetables().where((v) => v.suitableClimates.contains(climate)).toList();
    } catch (e) { debugPrint('=== getVegetablesByClimate error: $e ==='); return []; }
  }

  static Vegetable? getVegetableById(String id) {
    try {
      final box = _getBox(vegetablesBox);
      final map = box.get(id);
      return map != null ? _vegetableFromMap(Map<String, dynamic>.from(map)) : null;
    } catch (e) { debugPrint('=== getVegetableById error: $e ==='); return null; }
  }

  static List<Vegetable> searchVegetables(String query) {
    try {
      return getAllVegetables().where((v) => v.name.contains(query) || (v.alias?.contains(query) ?? false)).toList();
    } catch (e) { debugPrint('=== searchVegetables error: $e ==='); return []; }
  }

  static Future<void> saveVegetables(List<Vegetable> vegetables) async {
    try {
      final box = _getBox(vegetablesBox);
      for (final veg in vegetables) await box.put(veg.id, _vegetableToMap(veg));
    } catch (e) { debugPrint('=== saveVegetables error: $e ==='); }
  }

  // ========== 种植日历操作 ==========
  static Map<ClimateZone, Map<int, List<String>>> getPlantingCalendar() {
    try {
      final box = _getBox(calendarBox);
      final Map<ClimateZone, Map<int, List<String>>> result = {};
      for (final climate in ClimateZone.values) {
        final monthData = <int, List<String>>{};
        for (int month = 1; month <= 12; month++) {
          final key = '${climate.name}_$month';
          final value = box.get(key);
          monthData[month] = (value != null && value.isNotEmpty) ? value.split(',') : [];
        }
        result[climate] = monthData;
      }
      return result;
    } catch (e) { debugPrint('=== getPlantingCalendar error: $e ==='); return {}; }
  }

  static Future<void> savePlantingCalendar(Map<ClimateZone, Map<int, List<String>>> calendar) async {
    try {
      final box = _getBox(calendarBox);
      for (final climateEntry in calendar.entries) {
        for (final monthEntry in climateEntry.value.entries) {
          final key = '${climateEntry.key.name}_${monthEntry.key}';
          await box.put(key, monthEntry.value.join(','));
        }
      }
    } catch (e) { debugPrint('=== savePlantingCalendar error: $e ==='); }
  }

  static List<String> getVegetableIdsForClimateAndMonth(ClimateZone climate, int month) {
    try {
      return getPlantingCalendar()[climate]?[month] ?? [];
    } catch (e) { debugPrint('=== getVegetableIdsForClimateAndMonth error: $e ==='); return []; }
  }

  // ========== 菜园操作 ==========
  static List<GardenVegetable> getAllGardenVegetables() {
    try {
      return _getBox(gardenBox).values.map((map) => _gardenVegetableFromMap(Map<String, dynamic>.from(map))).toList();
    } catch (e) { debugPrint('=== getAllGardenVegetables error: $e ==='); return []; }
  }

  static GardenVegetable? getGardenVegetableById(String id) {
    try {
      final box = _getBox(gardenBox);
      final map = box.get(id);
      return map != null ? _gardenVegetableFromMap(Map<String, dynamic>.from(map)) : null;
    } catch (e) { debugPrint('=== getGardenVegetableById error: $e ==='); return null; }
  }

  static Future<GardenVegetable> addVegetableToGarden({
    required String vegetableId, required String vegetableName,
    required DateTime sowDate, BalconyDirection? sunlight,
  }) async {
    try {
      final box = _getBox(gardenBox);
      final now = DateTime.now();
      final id = '${now.millisecondsSinceEpoch}';
      final gv = GardenVegetable(
        id: id, vegetableId: vegetableId, vegetableName: vegetableName,
        sowDate: sowDate, sunlight: sunlight, status: GardenStatus.growing,
        createdAt: now, updatedAt: now, logs: const [], reminders: const [],
      );
      await box.put(id, _gardenVegetableToMap(gv));
      return gv;
    } catch (e) { debugPrint('=== addVegetableToGarden error: $e ==='); rethrow; }
  }

  static Future<void> updateGardenStatus(String id, GardenStatus status) async {
    try {
      final box = _getBox(gardenBox);
      final map = box.get(id);
      if (map != null) {
        final m = Map<String, dynamic>.from(map);
        m['status'] = status.name;
        m['updatedAt'] = DateTime.now().toIso8601String();
        await box.put(id, m);
      }
    } catch (e) { debugPrint('=== updateGardenStatus error: $e ==='); }
  }

  static Future<void> deleteGardenVegetable(String id) async {
    try { await _getBox(gardenBox).delete(id); } catch (e) { debugPrint('=== deleteGardenVegetable error: $e ==='); }
  }

  // ========== 转换函数 ==========
  static City _cityFromMap(Map<dynamic, dynamic> map) {
    return City(
      id: map['id'] as int?, name: map['name'] as String,
      province: map['province'] as String,
      climate: ClimateZone.fromString(map['climate_zone'] as String? ?? '') ?? ClimateZone.warmTemperate,
    );
  }

  static Map<String, dynamic> _cityToMap(City city) => {
    'id': city.id, 'name': city.name, 'province': city.province, 'climate_zone': city.climate.name,
  };

  static Vegetable _vegetableFromMap(Map<String, dynamic> map) {
    return Vegetable(
      id: map['id'] as String, name: map['name'] as String, alias: map['alias'] as String?,
      category: _parseVegetableCategory(map['category'] as String?),
      sunlight: _parseSunlightNeed(map['sunlight'] as String?),
      minTemp: _toDouble(map['minTemp'] ?? map['min_temp']) ?? 10.0,
      maxTemp: _toDouble(map['maxTemp'] ?? map['max_temp']) ?? 35.0,
      soil: SoilRequirement(
        type: map['soil_type'] as String? ?? '通用',
        phMin: _toDouble(map['soil_ph_min']) ?? 6.0, phMax: _toDouble(map['soil_ph_max']) ?? 7.5,
        drainage: map['soil_drainage'] as String? ?? '良好',
      ),
      fertilizer: Fertilizer(
        base: map['fertilizer_base'] as String? ?? '有机肥',
        top: map['fertilizer_top'] as String? ?? '复合肥',
      ),
      planting: PlantingInfo(
        depthCm: _toInt(map['planting_depth']) ?? 2, spacingCm: _toInt(map['planting_spacing']) ?? 30,
        rowSpacingCm: _toInt(map['planting_row_spacing']) ?? 40,
        germinationDays: _toInt(map['germination_days']) ?? 7, maturityDays: _toInt(map['maturity_days']) ?? 60,
      ),
      nutrients: _parseStringList(map['nutrients']), cautions: _parseStringList(map['cautions']),
      suitableClimates: _parseClimateZoneList(map['suitable_climates']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static VegetableCategory _parseVegetableCategory(String? v) {
    if (v == null) return VegetableCategory.leafy;
    return VegetableCategory.values.cast<VegetableCategory?>().firstWhere(
      (e) => e?.name == v || e?.label == v, orElse: () => VegetableCategory.leafy,
    ) ?? VegetableCategory.leafy;
  }

  static SunlightNeed _parseSunlightNeed(String? v) {
    if (v == null) return SunlightNeed.fullSun;
    return SunlightNeed.values.cast<SunlightNeed?>().firstWhere(
      (e) => e?.name == v || e?.label == v, orElse: () => SunlightNeed.fullSun,
    ) ?? SunlightNeed.fullSun;
  }

  static Map<String, dynamic> _vegetableToMap(Vegetable veg) => {
    'id': veg.id, 'name': veg.name, 'alias': veg.alias, 'category': veg.category.name,
    'sunlight': veg.sunlight.name, 'minTemp': veg.minTemp, 'maxTemp': veg.maxTemp,
    'soil_type': veg.soil.type, 'soil_ph_min': veg.soil.phMin, 'soil_ph_max': veg.soil.phMax,
    'soil_drainage': veg.soil.drainage, 'fertilizer_base': veg.fertilizer.base,
    'fertilizer_top': veg.fertilizer.top, 'planting_depth': veg.planting.depthCm,
    'planting_spacing': veg.planting.spacingCm, 'planting_row_spacing': veg.planting.rowSpacingCm,
    'germination_days': veg.planting.germinationDays, 'maturity_days': veg.planting.maturityDays,
    'nutrients': veg.nutrients.join(','), 'cautions': veg.cautions.join(','),
    'suitable_climates': veg.suitableClimates.map((c) => c.name).join(','),
  };

  static GardenVegetable _gardenVegetableFromMap(Map<String, dynamic> map) {
    return GardenVegetable(
      id: map['id'] as String, vegetableId: map['vegetable_id'] as String,
      vegetableName: map['vegetable_name'] as String,
      sowDate: DateTime.parse(map['sow_date'] as String),
      sunlight: map['sunlight'] != null
        ? BalconyDirection.values.cast<BalconyDirection?>().firstWhere(
            (e) => e?.name == map['sunlight'], orElse: () => BalconyDirection.none,
          ) ?? BalconyDirection.none : null,
      status: GardenStatus.values.cast<GardenStatus?>().firstWhere(
          (e) => e?.name == map['status'], orElse: () => GardenStatus.growing,
        ) ?? GardenStatus.growing,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      logs: const [], reminders: const [],
    );
  }

  static Map<String, dynamic> _gardenVegetableToMap(GardenVegetable gv) => {
    'id': gv.id, 'vegetable_id': gv.vegetableId, 'vegetable_name': gv.vegetableName,
    'sow_date': gv.sowDate.toIso8601String(), 'sunlight': gv.sunlight?.name,
    'status': gv.status.name, 'created_at': gv.createdAt.toIso8601String(),
    'updated_at': gv.updatedAt.toIso8601String(),
  };

  static List<String> _parseStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.cast<String>();
    if (v is String) return v.isEmpty ? [] : v.split(',');
    return [];
  }

  static List<ClimateZone> _parseClimateZoneList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => ClimateZone.fromString(e.toString())).whereType<ClimateZone>().toList();
    if (v is String) return v.isEmpty ? [] : v.split(',').map((e) => ClimateZone.fromString(e.trim())).whereType<ClimateZone>().toList();
    return [];
  }
}
