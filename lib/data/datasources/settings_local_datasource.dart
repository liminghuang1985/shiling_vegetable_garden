import 'package:shared_preferences/shared_preferences.dart';

/// 设置本地数据源 - 使用 SharedPreferences 持久化用户设置
class SettingsLocalDatasource {
  static const _keySelectedCityId = 'selected_city_id';
  static const _keySelectedClimate = 'selected_climate';
  static const _keyBalconyDirection = 'balcony_direction';

  // ========== 城市选择 ==========

  Future<void> saveSelectedCityId(int cityId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySelectedCityId, cityId);
  }

  Future<int?> getSelectedCityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySelectedCityId);
  }

  Future<void> clearSelectedCityId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedCityId);
  }

  // ========== 气候带选择 ==========

  Future<void> saveSelectedClimate(String climateName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedClimate, climateName);
  }

  Future<String?> getSelectedClimate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedClimate);
  }

  Future<void> clearSelectedClimate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedClimate);
  }

  // ========== 阳台朝向 ==========

  Future<void> saveBalconyDirection(String direction) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBalconyDirection, direction);
  }

  Future<String?> getBalconyDirection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBalconyDirection);
  }

  Future<void> clearBalconyDirection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBalconyDirection);
  }
}
