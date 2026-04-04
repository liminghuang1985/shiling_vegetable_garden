import '../entities/city.dart';
import '../../core/constants/enums.dart';

/// 城市仓储接口
abstract class CityRepository {
  /// 获取所有城市
  Future<List<City>> getAllCities();

  /// 按气候带获取城市
  Future<List<City>> getCitiesByClimate(ClimateZone climate);

  /// 搜索城市
  Future<List<City>> searchCities(String query);

  /// 获取城市详情
  Future<City?> getCityById(int id);

  /// 保存城市列表（批量）
  Future<void> saveCities(List<City> cities);

  /// 云端同步（预留接口）
  Future<void> syncFromCloud();
}
