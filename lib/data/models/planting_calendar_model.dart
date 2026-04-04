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
      3: ['菠菜', '小白菜'],
      4: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆'],
      5: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜'],
      6: ['黄瓜', '茄子', '菜豆', '南瓜', '豇豆'],
      7: ['萝卜', '白菜'],
      8: ['萝卜', '白菜'],
      9: ['菠菜', '香菜'],
    };
  }

  static Map<int, List<String>> _generateTemperateCalendar() {
    return {
      3: ['菠菜', '韭菜', '小白菜'],
      4: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜'],
      5: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜', '冬瓜'],
      6: ['黄瓜', '茄子', '菜豆', '豇豆', '丝瓜'],
      7: ['萝卜', '白菜', '芥菜'],
      8: ['萝卜', '白菜', '芥菜', '香菜'],
      9: ['菠菜', '香菜', '蒜苗'],
    };
  }

  static Map<int, List<String>> _generateWarmTemperateCalendar() {
    return {
      2: ['菠菜', '蒜苗'],
      3: ['菠菜', '韭菜', '小白菜', '菜苔'],
      4: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜', '苦瓜'],
      5: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜', '苦瓜', '丝瓜'],
      6: ['黄瓜', '茄子', '菜豆', '豇豆', '丝瓜', '空心菜'],
      7: ['萝卜', '白菜', '芥菜', '空心菜'],
      8: ['萝卜', '白菜', '芥菜', '香菜', '菠菜'],
      9: ['菠菜', '香菜', '蒜苗', '莴笋'],
      10: ['菠菜', '蒜苗'],
    };
  }

  static Map<int, List<String>> _generateSubtropicalCalendar() {
    return {
      1: ['菠菜', '蒜苗', '萝卜'],
      2: ['菠菜', '蒜苗', '萝卜', '菜苔'],
      3: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜'],
      4: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜', '苦瓜', '丝瓜'],
      5: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '苦瓜', '丝瓜', '空心菜'],
      6: ['黄瓜', '茄子', '菜豆', '豇豆', '丝瓜', '空心菜', '木耳菜'],
      7: ['萝卜', '白菜', '芥菜', '空心菜', '木耳菜'],
      8: ['萝卜', '白菜', '芥菜', '香菜', '菠菜'],
      9: ['菠菜', '香菜', '蒜苗', '莴笋', '菜苔'],
      10: ['菠菜', '蒜苗', '萝卜', '菜苔'],
      11: ['菠菜', '蒜苗', '萝卜'],
      12: ['菠菜', '蒜苗'],
    };
  }

  static Map<int, List<String>> _generateTropicalCalendar() {
    return {
      1: ['空心菜', '木耳菜', '苋菜'],
      2: ['空心菜', '木耳菜', '苋菜', '番茄'],
      3: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜', '苦瓜'],
      4: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜', '苦瓜', '丝瓜', '空心菜'],
      5: ['黄瓜', '茄子', '菜豆', '豇豆', '丝瓜', '空心菜', '木耳菜', '苋菜'],
      6: ['空心菜', '木耳菜', '苋菜', '豇豆'],
      7: ['空心菜', '木耳菜', '苋菜', '萝卜'],
      8: ['空心菜', '木耳菜', '苋菜', '萝卜', '白菜'],
      9: ['空心菜', '木耳菜', '苋菜', '萝卜', '白菜', '菠菜'],
      10: ['空心菜', '木耳菜', '苋菜', '菠菜', '蒜苗'],
      11: ['空心菜', '木耳菜', '菠菜', '蒜苗'],
      12: ['空心菜', '木耳菜', '苋菜'],
    };
  }

  static Map<int, List<String>> _generatePlateauCalendar() {
    return {
      3: ['菠菜', '小白菜'],
      4: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆'],
      5: ['番茄', '黄瓜', '辣椒', '茄子', '菜豆', '南瓜'],
      6: ['黄瓜', '茄子', '菜豆', '南瓜', '豇豆'],
      7: ['萝卜', '白菜'],
      8: ['萝卜', '白菜', '香菜'],
      9: ['菠菜', '香菜'],
    };
  }
}
