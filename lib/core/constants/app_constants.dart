/// App 全局常量
class AppConstants {
  /// App 信息
  static const String appName = '时令菜园';
  static const String appVersion = '1.0.0';

  /// 资源路径
  static const String assetsDataPath = 'assets/data/';
  static const String vegetablesJsonFile = 'vegetables.json';
  static const String citiesJsonFile = 'cities.json';
  static const String plantingCalendarJsonFile = 'planting_calendar.json';

  /// 预设城市数据（精简版示例）
  static const List<Map<String, dynamic>> presetCities = [
    {'name': '北京', 'province': '北京', 'climate_zone': '中温带'},
    {'name': '天津', 'province': '天津', 'climate_zone': '中温带'},
    {'name': '石家庄', 'province': '河北', 'climate_zone': '暖温带'},
    {'name': '太原', 'province': '山西', 'climate_zone': '中温带'},
    {'name': '呼和浩特', 'province': '内蒙古', 'climate_zone': '中温带'},
    {'name': '沈阳', 'province': '辽宁', 'climate_zone': '中温带'},
    {'name': '长春', 'province': '吉林', 'climate_zone': '寒温带'},
    {'name': '哈尔滨', 'province': '黑龙江', 'climate_zone': '寒温带'},
    {'name': '上海', 'province': '上海', 'climate_zone': '亚热带'},
    {'name': '南京', 'province': '江苏', 'climate_zone': '亚热带'},
    {'name': '杭州', 'province': '浙江', 'climate_zone': '亚热带'},
    {'name': '合肥', 'province': '安徽', 'climate_zone': '亚热带'},
    {'name': '福州', 'province': '福建', 'climate_zone': '亚热带'},
    {'name': '南昌', 'province': '江西', 'climate_zone': '亚热带'},
    {'name': '济南', 'province': '山东', 'climate_zone': '暖温带'},
    {'name': '郑州', 'province': '河南', 'climate_zone': '暖温带'},
    {'name': '武汉', 'province': '湖北', 'climate_zone': '亚热带'},
    {'name': '长沙', 'province': '湖南', 'climate_zone': '亚热带'},
    {'name': '广州', 'province': '广东', 'climate_zone': '热带'},
    {'name': '深圳', 'province': '广东', 'climate_zone': '热带'},
    {'name': '南宁', 'province': '广西', 'climate_zone': '热带'},
    {'name': '海口', 'province': '海南', 'climate_zone': '热带'},
    {'name': '重庆', 'province': '重庆', 'climate_zone': '亚热带'},
    {'name': '成都', 'province': '四川', 'climate_zone': '亚热带'},
    {'name': '贵阳', 'province': '贵州', 'climate_zone': '亚热带'},
    {'name': '昆明', 'province': '云南', 'climate_zone': '高原气候'},
    {'name': '拉萨', 'province': '西藏', 'climate_zone': '高原气候'},
    {'name': '西安', 'province': '陕西', 'climate_zone': '暖温带'},
    {'name': '兰州', 'province': '甘肃', 'climate_zone': '暖温带'},
    {'name': '西宁', 'province': '青海', 'climate_zone': '高原气候'},
    {'name': '银川', 'province': '宁夏', 'climate_zone': '中温带'},
    {'name': '乌鲁木齐', 'province': '新疆', 'climate_zone': '中温带'},
  ];

  /// SharedPreferences Keys
  static const String prefSelectedCity = 'selected_city';
  static const String prefClimateZone = 'climate_zone';
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefNotificationsEnabled = 'notifications_enabled';
}
