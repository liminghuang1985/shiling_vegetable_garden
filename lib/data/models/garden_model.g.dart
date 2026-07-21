// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GardenLogModel _$GardenLogModelFromJson(Map<String, dynamic> json) =>
    GardenLogModel(
      id: (json['id'] as num?)?.toInt(),
      gardenId: json['garden_id'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
      photoPath: json['photo_path'] as String?,
    );

Map<String, dynamic> _$GardenLogModelToJson(GardenLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'garden_id': instance.gardenId,
      'date': instance.date.toIso8601String(),
      'note': instance.note,
      'photo_path': instance.photoPath,
    };

ReminderModel _$ReminderModelFromJson(Map<String, dynamic> json) =>
    ReminderModel(
      id: json['id'] as String,
      gardenId: json['garden_id'] as String,
      type: $enumDecode(
        _$ReminderTypeEnumMap,
        json['type'],
        unknownValue: ReminderType.water,
      ),
      time: DateTime.parse(json['time'] as String),
      isDone: json['is_done'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ReminderModelToJson(ReminderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'garden_id': instance.gardenId,
      'time': instance.time.toIso8601String(),
      'is_done': instance.isDone,
      'created_at': instance.createdAt?.toIso8601String(),
      'type': _$ReminderTypeEnumMap[instance.type]!,
    };

const _$ReminderTypeEnumMap = {
  ReminderType.water: 'water',
  ReminderType.fertilize: 'fertilize',
  ReminderType.harvest: 'harvest',
};

GardenVegetableModel _$GardenVegetableModelFromJson(
  Map<String, dynamic> json,
) => GardenVegetableModel(
  id: json['id'] as String,
  vegetableId: json['vegetable_id'] as String,
  vegetableName: json['vegetable_name'] as String,
  sowDate: DateTime.parse(json['sow_date'] as String),
  sunlight: $enumDecodeNullable(
    _$BalconyDirectionEnumMap,
    json['sunlight'],
    unknownValue: BalconyDirection.none,
  ),
  status: $enumDecode(
    _$GardenStatusEnumMap,
    json['status'],
    unknownValue: GardenStatus.growing,
  ),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  logs: json['logs'] == null ? const [] : _logsFromJson(json['logs'] as List?),
  reminders: json['reminders'] == null
      ? const []
      : _remindersFromJson(json['reminders'] as List?),
);

Map<String, dynamic> _$GardenVegetableModelToJson(
  GardenVegetableModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'vegetable_id': instance.vegetableId,
  'vegetable_name': instance.vegetableName,
  'sow_date': instance.sowDate.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'sunlight': _$BalconyDirectionEnumMap[instance.sunlight],
  'status': _$GardenStatusEnumMap[instance.status]!,
  'logs': _logsToJson(instance.logs),
  'reminders': _remindersToJson(instance.reminders),
};

const _$BalconyDirectionEnumMap = {
  BalconyDirection.east: 'east',
  BalconyDirection.south: 'south',
  BalconyDirection.west: 'west',
  BalconyDirection.north: 'north',
  BalconyDirection.none: 'none',
};

const _$GardenStatusEnumMap = {
  GardenStatus.growing: 'growing',
  GardenStatus.harvested: 'harvested',
  GardenStatus.cancelled: 'cancelled',
};
