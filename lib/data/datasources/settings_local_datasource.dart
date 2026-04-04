import 'package:shared_preferences/shared_preferences.dart';

/// 设置本地数据源 - 使用 SharedPreferences 持久化用户设置
class SettingsLocalDatasource {
  static const _keySelectedCityId = 'selected_city_id';
  static const _keySelectedClimate = 'selected_climate';
  static const _keyBalconyDirection = 'balcony_direction';
  static const _keyReminderHarvest = 'reminder_harvest';
  static const _keyReminderWater = 'reminder_water';
  static const _keyReminderFertilize = 'reminder_fertilize';
  static const _keyNotificationsEnabled = 'notifications_enabled';

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

  // ========== 提醒设置 ==========

  Future<void> saveReminderSettings(bool harvest, bool water, bool fertilize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderHarvest, harvest);
    await prefs.setBool(_keyReminderWater, water);
    await prefs.setBool(_keyReminderFertilize, fertilize);
  }

  Future<Map<String, bool>> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'harvest': prefs.getBool(_keyReminderHarvest) ?? true,
      'water': prefs.getBool(_keyReminderWater) ?? true,
      'fertilize': prefs.getBool(_keyReminderFertilize) ?? false,
    };
  }

  // ========== 通知总开关 ==========

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }
}
