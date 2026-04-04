import '../../domain/entities/vegetable.dart';
import '../../core/constants/enums.dart';

/// 土壤要求数据模型
class SoilRequirementModel extends SoilRequirement {
  const SoilRequirementModel({
    required super.type,
    required super.phMin,
    required super.phMax,
    required super.drainage,
  });

  factory SoilRequirementModel.fromJson(Map<String, dynamic> json) {
    return SoilRequirementModel(
      type: json['type'] as String? ?? '通用',
      phMin: (json['ph_min'] as num?)?.toDouble() ?? 6.0,
      phMax: (json['ph_max'] as num?)?.toDouble() ?? 7.5,
      drainage: json['drainage'] as String? ?? '良好',
    );
  }

  factory SoilRequirementModel.fromMap(Map<String, dynamic> map) {
    return SoilRequirementModel(
      type: map['soil_type'] as String? ?? '通用',
      phMin: (map['soil_ph_min'] as num?)?.toDouble() ?? 6.0,
      phMax: (map['soil_ph_max'] as num?)?.toDouble() ?? 7.5,
      drainage: map['soil_drainage'] as String? ?? '良好',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'ph_min': phMin,
        'ph_max': phMax,
        'drainage': drainage,
      };

  Map<String, dynamic> toMap() => {
        'soil_type': type,
        'soil_ph_min': phMin,
        'soil_ph_max': phMax,
        'soil_drainage': drainage,
      };

  factory SoilRequirementModel.fromEntity(SoilRequirement soil) {
    return SoilRequirementModel(
      type: soil.type,
      phMin: soil.phMin,
      phMax: soil.phMax,
      drainage: soil.drainage,
    );
  }
}

/// 肥料建议数据模型
class FertilizerModel extends Fertilizer {
  const FertilizerModel({
    required super.base,
    required super.top,
  });

  factory FertilizerModel.fromJson(Map<String, dynamic> json) {
    return FertilizerModel(
      base: json['base'] as String? ?? '有机肥',
      top: json['top'] as String? ?? '复合肥',
    );
  }

  factory FertilizerModel.fromMap(Map<String, dynamic> map) {
    return FertilizerModel(
      base: map['fertilizer_base'] as String? ?? '有机肥',
      top: map['fertilizer_top'] as String? ?? '复合肥',
    );
  }

  Map<String, dynamic> toJson() => {'base': base, 'top': top};

  Map<String, dynamic> toMap() => {
        'fertilizer_base': base,
        'fertilizer_top': top,
      };

  factory FertilizerModel.fromEntity(Fertilizer fertilizer) {
    return FertilizerModel(
      base: fertilizer.base,
      top: fertilizer.top,
    );
  }
}

/// 种植信息数据模型
class PlantingInfoModel extends PlantingInfo {
  const PlantingInfoModel({
    required super.depthCm,
    required super.spacingCm,
    required super.rowSpacingCm,
    required super.germinationDays,
    required super.maturityDays,
  });

  factory PlantingInfoModel.fromJson(Map<String, dynamic> json) {
    return PlantingInfoModel(
      depthCm: json['depth_cm'] as int? ?? 2,
      spacingCm: json['spacing_cm'] as int? ?? 30,
      rowSpacingCm: json['row_spacing_cm'] as int? ?? 40,
      germinationDays: json['germination_days'] as int? ?? 7,
      maturityDays: json['maturity_days'] as int? ?? 60,
    );
  }

  factory PlantingInfoModel.fromMap(Map<String, dynamic> map) {
    return PlantingInfoModel(
      depthCm: map['planting_depth'] as int? ?? 2,
      spacingCm: map['planting_spacing'] as int? ?? 30,
      rowSpacingCm: map['planting_row_spacing'] as int? ?? 40,
      germinationDays: map['germination_days'] as int? ?? 7,
      maturityDays: map['maturity_days'] as int? ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
        'depth_cm': depthCm,
        'spacing_cm': spacingCm,
        'row_spacing_cm': rowSpacingCm,
        'germination_days': germinationDays,
        'maturity_days': maturityDays,
      };

  Map<String, dynamic> toMap() => {
        'planting_depth': depthCm,
        'planting_spacing': spacingCm,
        'planting_row_spacing': rowSpacingCm,
        'germination_days': germinationDays,
        'maturity_days': maturityDays,
      };

  factory PlantingInfoModel.fromEntity(PlantingInfo info) {
    return PlantingInfoModel(
      depthCm: info.depthCm,
      spacingCm: info.spacingCm,
      rowSpacingCm: info.rowSpacingCm,
      germinationDays: info.germinationDays,
      maturityDays: info.maturityDays,
    );
  }
}

/// 蔬菜数据模型
class VegetableModel extends Vegetable {
  const VegetableModel({
    required super.id,
    required super.name,
    super.alias,
    required super.category,
    required super.sunlight,
    required super.minTemp,
    required super.maxTemp,
    required super.soil,
    required super.fertilizer,
    required super.planting,
    required super.nutrients,
    required super.cautions,
    required super.suitableClimates,
  });

  /// 从 JSON 解析
  factory VegetableModel.fromJson(Map<String, dynamic> json) {
    return VegetableModel(
      id: json['id'] as String,
      name: json['name'] as String,
      alias: json['alias'] as String?,
      category: VegetableCategory.fromString(json['category'] as String) ?? VegetableCategory.leafy,
      sunlight: SunlightNeed.fromString(json['sunlight'] as String) ?? SunlightNeed.fullSun,
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 10.0,
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 35.0,
      soil: SoilRequirementModel.fromJson(json['soil'] as Map<String, dynamic>? ?? {}),
      fertilizer: FertilizerModel.fromJson(json['fertilizer'] as Map<String, dynamic>? ?? {}),
      planting: PlantingInfoModel.fromJson(json['planting'] as Map<String, dynamic>? ?? {}),
      nutrients: (json['nutrients'] as List<dynamic>?)?.cast<String>() ?? [],
      cautions: (json['cautions'] as List<dynamic>?)?.cast<String>() ?? [],
      suitableClimates: (json['suitable_climates'] as List<dynamic>?)
              ?.map((e) => ClimateZone.fromString(e as String))
              .whereType<ClimateZone>()
              .toList() ??
          [],
    );
  }

  /// 从数据库 Map 解析
  factory VegetableModel.fromMap(Map<String, dynamic> map) {
    return VegetableModel(
      id: map['id'] as String,
      name: map['name'] as String,
      alias: map['alias'] as String?,
      category: VegetableCategory.fromString(map['category'] as String) ?? VegetableCategory.leafy,
      sunlight: SunlightNeed.fromString(map['sunlight'] as String) ?? SunlightNeed.fullSun,
      minTemp: (map['min_temp'] as num?)?.toDouble() ?? 10.0,
      maxTemp: (map['max_temp'] as num?)?.toDouble() ?? 35.0,
      soil: SoilRequirementModel(
        type: map['soil_type'] as String? ?? '通用',
        phMin: (map['soil_ph_min'] as num?)?.toDouble() ?? 6.0,
        phMax: (map['soil_ph_max'] as num?)?.toDouble() ?? 7.5,
        drainage: map['soil_drainage'] as String? ?? '良好',
      ),
      fertilizer: FertilizerModel(
        base: map['fertilizer_base'] as String? ?? '有机肥',
        top: map['fertilizer_top'] as String? ?? '复合肥',
      ),
      planting: PlantingInfoModel(
        depthCm: map['planting_depth'] as int? ?? 2,
        spacingCm: map['planting_spacing'] as int? ?? 30,
        rowSpacingCm: map['planting_row_spacing'] as int? ?? 40,
        germinationDays: map['germination_days'] as int? ?? 7,
        maturityDays: map['maturity_days'] as int? ?? 60,
      ),
      nutrients: _parseStringList(map['nutrients']),
      cautions: _parseStringList(map['cautions']),
      suitableClimates: _parseClimateZoneList(map['suitable_climates']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    if (value is String) {
      if (value.isEmpty) return [];
      return value.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  static List<ClimateZone> _parseClimateZoneList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => ClimateZone.fromString(e.toString()))
          .whereType<ClimateZone>()
          .toList();
    }
    if (value is String) {
      if (value.isEmpty) return [];
      return value
          .split(',')
          .map((e) => ClimateZone.fromString(e.trim()))
          .whereType<ClimateZone>()
          .toList();
    }
    return [];
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'category': category.name,
      'sunlight': sunlight.name,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'soil': SoilRequirementModel.fromEntity(soil).toJson(),
      'fertilizer': FertilizerModel.fromEntity(fertilizer).toJson(),
      'planting': PlantingInfoModel.fromEntity(planting).toJson(),
      'nutrients': nutrients,
      'cautions': cautions,
      'suitable_climates': suitableClimates.map((e) => e.name).toList(),
    };
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'category': category.name,
      'sunlight': sunlight.name,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'soil_type': soil.type,
      'soil_ph_min': soil.phMin,
      'soil_ph_max': soil.phMax,
      'soil_drainage': soil.drainage,
      'fertilizer_base': fertilizer.base,
      'fertilizer_top': fertilizer.top,
      'planting_depth': planting.depthCm,
      'planting_spacing': planting.spacingCm,
      'planting_row_spacing': planting.rowSpacingCm,
      'germination_days': planting.germinationDays,
      'maturity_days': planting.maturityDays,
      'nutrients': nutrients.join(','),
      'cautions': cautions.join(','),
      'suitable_climates': suitableClimates.map((e) => e.name).join(','),
    };
  }

  /// 从实体转换
  factory VegetableModel.fromEntity(Vegetable vegetable) {
    return VegetableModel(
      id: vegetable.id,
      name: vegetable.name,
      alias: vegetable.alias,
      category: vegetable.category,
      sunlight: vegetable.sunlight,
      minTemp: vegetable.minTemp,
      maxTemp: vegetable.maxTemp,
      soil: vegetable.soil,
      fertilizer: vegetable.fertilizer,
      planting: vegetable.planting,
      nutrients: vegetable.nutrients,
      cautions: vegetable.cautions,
      suitableClimates: vegetable.suitableClimates,
    );
  }

  /// 转换为实体
  Vegetable toEntity() {
    return Vegetable(
      id: id,
      name: name,
      alias: alias,
      category: category,
      sunlight: sunlight,
      minTemp: minTemp,
      maxTemp: maxTemp,
      soil: soil,
      fertilizer: fertilizer,
      planting: planting,
      nutrients: nutrients,
      cautions: cautions,
      suitableClimates: suitableClimates,
    );
  }
}
