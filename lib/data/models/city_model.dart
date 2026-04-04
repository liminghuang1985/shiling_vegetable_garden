import '../../domain/entities/city.dart';
import '../../core/constants/enums.dart';

/// 城市数据模型 - 支持 JSON 序列化
class CityModel extends City {
  const CityModel({
    super.id,
    required super.name,
    required super.province,
    required super.climate,
  });

  /// 从 JSON 解析
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      province: json['province'] as String,
      climate: ClimateZone.fromString(json['climate_zone'] as String) ?? ClimateZone.warmTemperate,
    );
  }

  /// 从数据库 Map 解析
  factory CityModel.fromMap(Map<String, dynamic> map) {
    return CityModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      province: map['province'] as String,
      climate: ClimateZone.fromString(map['climate_zone'] as String) ?? ClimateZone.warmTemperate,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'province': province,
      'climate_zone': climate.name,
    };
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'province': province,
      'climate_zone': climate.name,
    };
  }

  /// 从实体转换
  factory CityModel.fromEntity(City city) {
    return CityModel(
      id: city.id,
      name: city.name,
      province: city.province,
      climate: city.climate,
    );
  }

  /// 转换为实体
  City toEntity() {
    return City(
      id: id,
      name: name,
      province: province,
      climate: climate,
    );
  }
}
