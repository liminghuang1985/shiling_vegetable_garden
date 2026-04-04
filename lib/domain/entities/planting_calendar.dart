import '../../core/constants/enums.dart';

/// 种植日历条目
class PlantingCalendarEntry {
  final ClimateZone climateZone;
  final int month;
  final List<String> vegetableIds;

  const PlantingCalendarEntry({
    required this.climateZone,
    required this.month,
    required this.vegetableIds,
  });

  @override
  String toString() =>
      'PlantingCalendarEntry(climate: ${climateZone.label}, month: $month, vegetables: ${vegetableIds.length})';
}

/// 完整的种植日历数据结构
/// Map<ClimateZone, Map<int, List<String>>>
/// 例: 暖温带[4月] → [番茄ID, 黄瓜ID, 辣椒ID...]
class PlantingCalendar {
  final Map<ClimateZone, Map<int, List<String>>> data;

  const PlantingCalendar({required this.data});

  /// 获取指定气候带和月份可种的蔬菜ID列表
  List<String> getVegetableIds(ClimateZone zone, int month) {
    return data[zone]?[month] ?? [];
  }

  /// 获取指定气候带可种的蔬菜ID列表（所有月份汇总）
  List<String> getAllVegetableIdsForClimate(ClimateZone zone) {
    final monthData = data[zone];
    if (monthData == null) return [];
    
    final Set<String> ids = {};
    for (final vegetables in monthData.values) {
      ids.addAll(vegetables);
    }
    return ids.toList();
  }

  /// 获取指定气候带某蔬菜的推荐种植月份
  List<int> getPlantingMonths(ClimateZone zone, String vegetableId) {
    final monthData = data[zone];
    if (monthData == null) return [];
    
    return monthData.entries
        .where((entry) => entry.value.contains(vegetableId))
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  /// 获取当前月份指定气候带可种的蔬菜
  List<String> getCurrentSeasonVegetables(ClimateZone zone) {
    final currentMonth = DateTime.now().month;
    return getVegetableIds(zone, currentMonth);
  }

  /// 获取下个月指定气候带可种的蔬菜
  List<String> getNextSeasonVegetables(ClimateZone zone) {
    final nextMonth = ((DateTime.now().month) % 12) + 1;
    return getVegetableIds(zone, nextMonth);
  }

  @override
  String toString() => 'PlantingCalendar(climates: ${data.keys.length})';
}
