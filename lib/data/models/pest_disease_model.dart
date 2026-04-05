/// 病虫害数据模型
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

  factory PestDiseaseModel.fromJson(Map<String, dynamic> json) {
    return PestDiseaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      targetVegetables: (json['targetVegetables'] as List<dynamic>?)?.cast<String>() ?? [],
      alias: json['alias'] as String?,
      symptoms: json['symptoms'] as String? ?? '',
      conditions: json['conditions'] as String? ?? '',
      season: json['season'] as String? ?? '',
      prevention: (json['prevention'] as List<dynamic>?)?.cast<String>() ?? [],
      biological: (json['biological'] as List<dynamic>?)?.cast<String>() ?? [],
      physical: (json['physical'] as List<dynamic>?)?.cast<String>() ?? [],
      chemical: json['chemical'] as String?,
      severity: json['severity'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'targetVegetables': targetVegetables,
    'alias': alias,
    'symptoms': symptoms,
    'conditions': conditions,
    'season': season,
    'prevention': prevention,
    'biological': biological,
    'physical': physical,
    'chemical': chemical,
    'severity': severity,
  };
}
