// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pest_disease_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PestDiseaseModel _$PestDiseaseModelFromJson(Map<String, dynamic> json) =>
    PestDiseaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      targetVegetables: (json['targetVegetables'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alias: json['alias'] as String?,
      symptoms: json['symptoms'] as String,
      conditions: json['conditions'] as String,
      season: json['season'] as String,
      prevention: (json['prevention'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      biological: (json['biological'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      physical: (json['physical'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      chemical: json['chemical'] as String?,
      severity: json['severity'] as String,
    );

Map<String, dynamic> _$PestDiseaseModelToJson(PestDiseaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'targetVegetables': instance.targetVegetables,
      'alias': instance.alias,
      'symptoms': instance.symptoms,
      'conditions': instance.conditions,
      'season': instance.season,
      'prevention': instance.prevention,
      'biological': instance.biological,
      'physical': instance.physical,
      'chemical': instance.chemical,
      'severity': instance.severity,
    };
