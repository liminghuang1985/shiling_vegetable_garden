import '../entities/vegetable.dart';
import '../entities/planting_calendar.dart';
import '../../core/constants/enums.dart';

/// 蔬菜仓储接口
abstract class VegetableRepository {
  /// 获取所有蔬菜
  Future<List<Vegetable>> getAllVegetables();

  /// 按分类获取蔬菜
  Future<List<Vegetable>> getVegetablesByCategory(VegetableCategory category);

  /// 按气候带获取适合的蔬菜
  Future<List<Vegetable>> getVegetablesByClimate(ClimateZone climate);

  /// 获取蔬菜详情
  Future<Vegetable?> getVegetableById(String id);

  /// 搜索蔬菜
  Future<List<Vegetable>> searchVegetables(String query);

  /// 保存蔬菜列表（批量）
  Future<void> saveVegetables(List<Vegetable> vegetables);

  /// 获取种植日历
  Future<PlantingCalendar> getPlantingCalendar();

  /// 获取指定气候带和月份的推荐蔬菜
  Future<List<Vegetable>> getRecommendedVegetables(ClimateZone climate, int month);

  /// 云端同步（预留接口）
  Future<void> syncFromCloud();
}
