/// 气候带枚举 - 基于中国气候带分类
enum ClimateZone {
  /// 寒温带 - 东北地区（黑龙江北部）
  coldTemperate('寒温带', '东北北部'),

  /// 中温带 - 华北北部（河北、北京、天津、山西、内蒙古中部）
  temperate('中温带', '华北北部'),

  /// 暖温带 - 华北南部/西北（山东、河南、陕西、甘肃南部）
  warmTemperate('暖温带', '华北南部/西北'),

  /// 亚热带 - 华中/华东/华南北部（江苏、安徽、浙江、湖北、湖南、江西、四川、重庆、福建北部、广东北部）
  subtropical('亚热带', '华中/华东'),

  /// 热带 - 华南（海南、广东南部、广西南部、云南南部）
  tropical('热带', '华南'),

  /// 高原气候 - 云南/西藏/青海（高原地区）
  plateau('高原气候', '云南/西藏/青海');

  final String label;
  final String region;

  const ClimateZone(this.label, this.region);

  static ClimateZone? fromString(String value) {
    return ClimateZone.values.cast<ClimateZone?>().firstWhere(
      (e) => e?.name == value || e?.label == value,
      orElse: () => null,
    );
  }
}

/// 蔬菜分类枚举
enum VegetableCategory {
  leafy('叶菜', '🥬'),
  fruit('果菜', '🍅'),
  root('根茎', '🥕'),
  legume('豆类', '🫘'),
  herb('香草', '🌿');

  final String label;
  final String emoji;

  const VegetableCategory(this.label, this.emoji);

  static VegetableCategory? fromString(String value) {
    return VegetableCategory.values.cast<VegetableCategory?>().firstWhere(
      (e) => e?.name == value || e?.label == value,
      orElse: () => null,
    );
  }
}

/// 光照需求枚举
enum SunlightNeed {
  fullSun('喜阳', '需要充足阳光，每天至少6小时直射阳光'),
  partialSun('喜阴', '喜欢半阴环境，避免强烈直射阳光'),
  shadeTolerant('耐阴', '可以在阴凉环境生长，但也能耐受阳光');

  final String label;
  final String description;

  const SunlightNeed(this.label, this.description);

  static SunlightNeed? fromString(String value) {
    return SunlightNeed.values.cast<SunlightNeed?>().firstWhere(
      (e) => e?.name == value || e?.label == value,
      orElse: () => null,
    );
  }
}

/// 用户菜园状态枚举
enum GardenStatus {
  growing('生长中', '🌱'),
  harvested('已收获', '✅'),
  cancelled('已取消', '❌');

  final String label;
  final String emoji;

  const GardenStatus(this.label, this.emoji);
}

/// 提醒类型枚举
enum ReminderType {
  water('浇水', '💧'),
  fertilize('施肥', '🧪'),
  harvest('收获', '🌾');

  final String label;
  final String emoji;

  const ReminderType(this.label, this.emoji);
}

/// 阳台朝向枚举
enum BalconyDirection {
  east('东', '☀️', '上午阳光充足'),
  south('南', '☀️☀️', '阳光最充足'),
  west('西', '☀️', '下午阳光充足'),
  north('北', '🌤️', '阳光较少'),
  none('无阳台', '🏠', '室内/无直射阳光');

  final String label;
  final String emoji;
  final String description;

  const BalconyDirection(this.label, this.emoji, this.description);
}
