import 'package:json_annotation/json_annotation.dart';

part 'pest_disease_model.g.dart';

/// 病虫害数据模型
@JsonSerializable(explicitToJson: false)
class PestDiseaseModel {
  final String id;
  final String name;
  final String type; // disease | pest
  final List<String> targetVegetables;
  final String? alias;
  final String symptoms;
  final String conditions;
  final String season;
  final List<String> prevention;
  final List<String> biological;
  final List<String> physical;
  final String? chemical;
  final String severity; // high | medium | low

  const PestDiseaseModel({
    required this.id,
    required this.name,
    required this.type,
    required this.targetVegetables,
    this.alias,
    required this.symptoms,
    required this.conditions,
    required this.season,
    required this.prevention,
    required this.biological,
    required this.physical,
    this.chemical,
    required this.severity,
  });

  bool get isDisease => type == 'disease';
  bool get isPest => type == 'pest';

  String get typeLabel => isDisease ? '病害' : '虫害';

  String get severityLabel {
    switch (severity) {
      case 'high':
        return '高危';
      case 'medium':
        return '中等';
      case 'low':
        return '轻微';
      default:
        return severity;
    }
  }

  String get severityEmoji {
    switch (severity) {
      case 'high':
        return '🔴';
      case 'medium':
        return '🟡';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }

  factory PestDiseaseModel.fromJson(Map<String, dynamic> json) =>
      _$PestDiseaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PestDiseaseModelToJson(this);
}
