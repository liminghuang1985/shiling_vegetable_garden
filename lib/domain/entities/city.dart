import '../../core/constants/enums.dart';

/// 城市实体 - 城市-气候带映射
class City {
  final int? id;
  final String name;
  final String province;
  final ClimateZone climate;

  const City({
    this.id,
    required this.name,
    required this.province,
    required this.climate,
  });

  City copyWith({
    int? id,
    String? name,
    String? province,
    ClimateZone? climate,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      climate: climate ?? this.climate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.name == name && other.province == province;
  }

  @override
  int get hashCode => name.hashCode ^ province.hashCode;

  @override
  String toString() => 'City(name: $name, province: $province, climate: ${climate.label})';
}
