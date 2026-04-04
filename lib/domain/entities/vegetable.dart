import '../../core/constants/enums.dart';

/// 土壤要求
class SoilRequirement {
  final String type;
  final double phMin;
  final double phMax;
  final String drainage;

  const SoilRequirement({
    required this.type,
    required this.phMin,
    required this.phMax,
    required this.drainage,
  });

  String get phRange => '${phMin.toStringAsFixed(1)} - ${phMax.toStringAsFixed(1)}';

  @override
  String toString() => 'SoilRequirement(type: $type, pH: $phRange, drainage: $drainage)';
}

/// 肥料建议
class Fertilizer {
  final String base;
  final String top;

  const Fertilizer({
    required this.base,
    required this.top,
  });

  @override
  String toString() => 'Fertilizer(base: $base, top: $top)';
}

/// 种植信息
class PlantingInfo {
  final int depthCm;
  final int spacingCm;
  final int rowSpacingCm;
  final int germinationDays;
  final int maturityDays;

  const PlantingInfo({
    required this.depthCm,
    required this.spacingCm,
    required this.rowSpacingCm,
    required this.germinationDays,
    required this.maturityDays,
  });

  String get spacingDesc => '株距 $spacingCm cm, 行距 $rowSpacingCm cm';

  @override
  String toString() =>
      'PlantingInfo(depth: ${depthCm}cm, spacing: $spacingCm, rowSpacing: $rowSpacingCm, germination: $germinationDays, maturity: $maturityDays)';
}

/// 蔬菜实体
class Vegetable {
  final String id;
  final String name;
  final String? alias;
  final VegetableCategory category;
  final SunlightNeed sunlight;
  final double minTemp;
  final double maxTemp;
  final SoilRequirement soil;
  final Fertilizer fertilizer;
  final PlantingInfo planting;
  final List<String> nutrients;
  final List<String> cautions;
  final List<ClimateZone> suitableClimates;

  const Vegetable({
    required this.id,
    required this.name,
    this.alias,
    required this.category,
    required this.sunlight,
    required this.minTemp,
    required this.maxTemp,
    required this.soil,
    required this.fertilizer,
    required this.planting,
    required this.nutrients,
    required this.cautions,
    required this.suitableClimates,
  });

  /// 温度范围描述
  String get tempRange => '${minTemp.toStringAsFixed(0)}°C - ${maxTemp.toStringAsFixed(0)}°C';

  /// 是否适合指定气候带
  bool isSuitableFor(ClimateZone zone) => suitableClimates.contains(zone);

  Vegetable copyWith({
    String? id,
    String? name,
    String? alias,
    VegetableCategory? category,
    SunlightNeed? sunlight,
    double? minTemp,
    double? maxTemp,
    SoilRequirement? soil,
    Fertilizer? fertilizer,
    PlantingInfo? planting,
    List<String>? nutrients,
    List<String>? cautions,
    List<ClimateZone>? suitableClimates,
  }) {
    return Vegetable(
      id: id ?? this.id,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      category: category ?? this.category,
      sunlight: sunlight ?? this.sunlight,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      soil: soil ?? this.soil,
      fertilizer: fertilizer ?? this.fertilizer,
      planting: planting ?? this.planting,
      nutrients: nutrients ?? this.nutrients,
      cautions: cautions ?? this.cautions,
      suitableClimates: suitableClimates ?? this.suitableClimates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vegetable && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Vegetable(id: $id, name: $name, category: ${category.label})';
}
