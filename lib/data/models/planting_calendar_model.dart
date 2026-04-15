import '../../domain/entities/planting_calendar.dart';
import '../../core/constants/enums.dart';

/// 种植日历数据模型
class PlantingCalendarModel extends PlantingCalendar {
  const PlantingCalendarModel({required super.data});

  /// 从 JSON 解析
  factory PlantingCalendarModel.fromJson(Map<String, dynamic> json) {
    final Map<ClimateZone, Map<int, List<String>>> parsedData = {};

    for (final climateEntry in json.entries) {
      final climate = ClimateZone.fromString(climateEntry.key);
      if (climate == null) continue;

      final monthData = climateEntry.value as Map<String, dynamic>;
      final Map<int, List<String>> monthVegs = {};

      for (final monthEntry in monthData.entries) {
        final month = int.tryParse(monthEntry.key);
        if (month == null) continue;

        final vegIds = (monthEntry.value as List<dynamic>).cast<String>();
        monthVegs[month] = vegIds;
      }

      parsedData[climate] = monthVegs;
    }

    return PlantingCalendarModel(data: parsedData);
  }

  /// 从数据库记录解析
  factory PlantingCalendarModel.fromDbRecords(List<Map<String, dynamic>> records) {
    final Map<ClimateZone, Map<int, List<String>>> parsedData = {};

    for (final record in records) {
      final climate = ClimateZone.fromString(record['climate_zone'] as String);
      if (climate == null) continue;

      final month = record['month'] as int;
      final vegIdsString = record['vegetable_ids'] as String;

      if (!parsedData.containsKey(climate)) {
        parsedData[climate] = {};
      }

      if (vegIdsString.isNotEmpty) {
        parsedData[climate]![month] = vegIdsString.split(',');
      } else {
        parsedData[climate]![month] = [];
      }
    }

    return PlantingCalendarModel(data: parsedData);
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};

    for (final climateEntry in data.entries) {
      final Map<String, List<String>> monthData = {};
      for (final monthEntry in climateEntry.value.entries) {
        monthData[monthEntry.key.toString()] = monthEntry.value;
      }
      result[climateEntry.key.name] = monthData;
    }

    return result;
  }

  /// 转换为数据库记录列表
  List<Map<String, dynamic>> toDbRecords() {
    final List<Map<String, dynamic>> records = [];

    for (final climateEntry in data.entries) {
      for (final monthEntry in climateEntry.value.entries) {
        records.add({
          'climate_zone': climateEntry.key.name,
          'month': monthEntry.key,
          'vegetable_ids': monthEntry.value.join(','),
        });
      }
    }

    return records;
  }

  /// 生成示例种植日历数据
  static PlantingCalendarModel generateSampleCalendar() {
    final Map<ClimateZone, Map<int, List<String>>> data = {};

    // 寒温带（东北）
    data[ClimateZone.coldTemperate] = _generateColdTemperateCalendar();

    // 中温带（华北北部）
    data[ClimateZone.temperate] = _generateTemperateCalendar();

    // 暖温带（华北南部/西北）
    data[ClimateZone.warmTemperate] = _generateWarmTemperateCalendar();

    // 亚热带（华中/华东）
    data[ClimateZone.subtropical] = _generateSubtropicalCalendar();

    // 热带（华南）
    data[ClimateZone.tropical] = _generateTropicalCalendar();

    // 高原气候（云南/西藏/青海）
    data[ClimateZone.plateau] = _generatePlateauCalendar();

    return PlantingCalendarModel(data: data);
  }

  static Map<int, List<String>> _generateColdTemperateCalendar() {
    return {
      3: ['xbc', 'sc', 'bc', 'hlb'],
      4: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'bc', 'hlb', 'bhc'],
      5: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'sc', 'bc', 'hlb', 'bhc', 'xc'],
      6: ['hg', 'qz', 'sjc', 'ng', 'dg', 'hlb', 'bhc', 'xc', 'lsc', 'md'],
      7: ['fq', 'hg', 'lj', 'sjc', 'ng', 'dg', 'lsc', 'md', 'bhc'],
      8: ['sjc', 'ng', 'lsc', 'md', 'bhc'],
      9: ['xbc', 'sc', 'bc', 'hlb', 'bhc'],
      10: ['xbc', 'sc', 'bc', 'hlb'],
    };
  }

  static Map<int, List<String>> _generateTemperateCalendar() {
    return {
      3: ['xbc', 'sc', 'bc', 'hlb', 'ws'],
      4: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'bc', 'hlb', 'ws', 'bhc', 'xc'],
      5: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh'],
      6: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'xlh', 'hyc'],
      7: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc'],
      8: ['sjc', 'ng', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc'],
      9: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'kxc'],
      10: ['xbc', 'sc', 'bc', 'hlb', 'ws'],
      11: ['sc', 'bc', 'hlb'],
    };
  }

  static Map<int, List<String>> _generateWarmTemperateCalendar() {
    return {
      1: ['xbc', 'sc', 'bc', 'hlb', 'ws'],
      2: ['xbc', 'sc', 'bc', 'hlb', 'ws'],
      3: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc'],
      4: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'ymc', 'npc', 'szc', 'zmc'],
      5: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'ymc', 'npc', 'szc', 'zmc', 'am', 'hsy'],
      6: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'ymc', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl'],
      7: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'tg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'ymc', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl'],
      8: ['sjc', 'ng', 'tg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'ymc', 'npc', 'szc', 'zmc', 'am'],
      9: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'npc', 'szc', 'zmc', 'ct', 'wdj'],
      10: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'npc', 'szc', 'zmc', 'ct', 'wdj'],
      11: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'ct', 'wdj'],
      12: ['xbc', 'sc', 'bc', 'hlb'],
    };
  }

  static Map<int, List<String>> _generateSubtropicalCalendar() {
    return {
      1: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'ct', 'wdj'],
      2: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'ct', 'wdj'],
      3: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'ct', 'wdj', 'npc', 'szc'],
      4: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq'],
      5: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec'],
      6: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll'],
      7: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'tg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'mec', 'll'],
      8: ['sjc', 'ng', 'tg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'mec', 'll', 'zs'],
      9: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'npc', 'szc', 'zmc', 'ct', 'wdj', 'am', 'hsy', 'zs'],
      10: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'npc', 'szc', 'zmc', 'ct', 'wdj', 'zs'],
      11: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'ct', 'wdj', 'zs'],
      12: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'ct', 'wdj'],
    };
  }

  static Map<int, List<String>> _generateTropicalCalendar() {
    return {
      1: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      2: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      3: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      4: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      5: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      6: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      7: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      8: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      9: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      10: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'hyc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      11: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
      12: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'tg', 'sc', 'bc', 'hlb', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'fsg', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec', 'll', 'zs'],
    };
  }

  static Map<int, List<String>> _generatePlateauCalendar() {
    return {
      3: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'ct', 'wdj'],
      4: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'ct', 'wdj', 'npc', 'szc'],
      5: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'xlh', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy'],
      6: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'dg', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'xlh', 'hyc', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'zbthk', 'tsq', 'mec'],
      7: ['fq', 'hg', 'lj', 'qz', 'sjc', 'ng', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'mec'],
      8: ['sjc', 'ng', 'lsc', 'md', 'bhc', 'xc', 'kxc', 'hyc', 'ct', 'wdj', 'npc', 'szc', 'zmc', 'am', 'hsy', 'cxl', 'mec'],
      9: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'bhc', 'xc', 'lsc', 'md', 'kxc', 'ct', 'wdj', 'npc', 'szc', 'zmc'],
      10: ['xbc', 'sc', 'bc', 'hlb', 'ws', 'ct', 'wdj', 'npc', 'szc'],
    };
  }
}
