import '../../domain/entities/city.dart';
import '../../core/constants/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'city_model.g.dart';

/// 城市数据模型 - 支持 JSON 序列化
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: false)
class CityModel extends City {
  const CityModel({
    super.id,
    required super.name,
    required super.province,
    required super.climate,
  });

  /// 从 JSON 解析
  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);

  @JsonKey(
    name: 'climate_zone',
    fromJson: _climateFromJson,
    toJson: _climateToJson,
  )
  @override
  ClimateZone get climate => super.climate;

  /// 从数据库 Map 解析
  factory CityModel.fromMap(Map<String, dynamic> map) {
    return CityModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      province: map['province'] as String,
      climate:
          ClimateZone.fromString(map['climate_zone'] as String) ??
          ClimateZone.warmTemperate,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$CityModelToJson(this);

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
    return City(id: id, name: name, province: province, climate: climate);
  }
}

ClimateZone _climateFromJson(String value) =>
    ClimateZone.fromString(value) ?? ClimateZone.warmTemperate;

String _climateToJson(ClimateZone climate) => climate.name;
