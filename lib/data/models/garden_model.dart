import '../../domain/entities/garden_vegetable.dart';
import '../../core/constants/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'garden_model.g.dart';

/// 生长日志数据模型
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: false)
class GardenLogModel extends GardenLog {
  const GardenLogModel({
    super.id,
    required super.gardenId,
    required super.date,
    required super.note,
    super.photoPath,
  });

  factory GardenLogModel.fromJson(Map<String, dynamic> json) =>
      _$GardenLogModelFromJson(json);

  factory GardenLogModel.fromMap(Map<String, dynamic> map) {
    return GardenLogModel(
      id: map['id'] as int?,
      gardenId: map['garden_id'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String,
      photoPath: map['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$GardenLogModelToJson(this);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'garden_id': gardenId,
    'date': date.toIso8601String(),
    'note': note,
    'photo_path': photoPath,
  };

  factory GardenLogModel.fromEntity(GardenLog log) {
    return GardenLogModel(
      id: log.id,
      gardenId: log.gardenId,
      date: log.date,
      note: log.note,
      photoPath: log.photoPath,
    );
  }

  GardenLog toEntity() {
    return GardenLog(
      id: id,
      gardenId: gardenId,
      date: date,
      note: note,
      photoPath: photoPath,
    );
  }
}

/// 提醒数据模型
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: false)
class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.gardenId,
    required super.type,
    required super.time,
    super.isDone = false,
    super.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) =>
      _$ReminderModelFromJson(json);

  @JsonKey(unknownEnumValue: ReminderType.water)
  @override
  ReminderType get type => super.type;

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      gardenId: map['garden_id'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.water,
      ),
      time: DateTime.parse(map['time'] as String),
      isDone: (map['is_done'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$ReminderModelToJson(this);

  Map<String, dynamic> toMap() => {
    'id': id,
    'garden_id': gardenId,
    'type': type.name,
    'time': time.toIso8601String(),
    'is_done': isDone ? 1 : 0,
    'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      gardenId: reminder.gardenId,
      type: reminder.type,
      time: reminder.time,
      isDone: reminder.isDone,
      createdAt: reminder.createdAt,
    );
  }

  Reminder toEntity() {
    return Reminder(
      id: id,
      gardenId: gardenId,
      type: type,
      time: time,
      isDone: isDone,
      createdAt: createdAt,
    );
  }
}

/// 用户菜园蔬菜数据模型
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: false)
class GardenVegetableModel extends GardenVegetable {
  const GardenVegetableModel({
    required super.id,
    required super.vegetableId,
    required super.vegetableName,
    required super.sowDate,
    super.sunlight,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.logs = const [],
    super.reminders = const [],
  });

  factory GardenVegetableModel.fromJson(Map<String, dynamic> json) =>
      _$GardenVegetableModelFromJson(json);

  @JsonKey(unknownEnumValue: BalconyDirection.none)
  @override
  BalconyDirection? get sunlight => super.sunlight;

  @JsonKey(unknownEnumValue: GardenStatus.growing)
  @override
  GardenStatus get status => super.status;

  @JsonKey(fromJson: _logsFromJson, toJson: _logsToJson)
  @override
  List<GardenLog> get logs => super.logs;

  @JsonKey(fromJson: _remindersFromJson, toJson: _remindersToJson)
  @override
  List<Reminder> get reminders => super.reminders;

  factory GardenVegetableModel.fromMap(Map<String, dynamic> map) {
    return GardenVegetableModel(
      id: map['id'] as String,
      vegetableId: map['vegetable_id'] as String,
      vegetableName: map['vegetable_name'] as String,
      sowDate: DateTime.parse(map['sow_date'] as String),
      sunlight: map['sunlight'] != null
          ? BalconyDirection.values.firstWhere(
              (e) => e.name == map['sunlight'],
              orElse: () => BalconyDirection.none,
            )
          : null,
      status: GardenStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GardenStatus.growing,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$GardenVegetableModelToJson(this);

  Map<String, dynamic> toMap() => {
    'id': id,
    'vegetable_id': vegetableId,
    'vegetable_name': vegetableName,
    'sow_date': sowDate.toIso8601String(),
    'sunlight': sunlight?.name,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory GardenVegetableModel.fromEntity(GardenVegetable gv) {
    return GardenVegetableModel(
      id: gv.id,
      vegetableId: gv.vegetableId,
      vegetableName: gv.vegetableName,
      sowDate: gv.sowDate,
      sunlight: gv.sunlight,
      status: gv.status,
      createdAt: gv.createdAt,
      updatedAt: gv.updatedAt,
      logs: gv.logs,
      reminders: gv.reminders,
    );
  }

  GardenVegetable toEntity() {
    return GardenVegetable(
      id: id,
      vegetableId: vegetableId,
      vegetableName: vegetableName,
      sowDate: sowDate,
      sunlight: sunlight,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      logs: logs,
      reminders: reminders,
    );
  }

  /// 复制并附加日志和提醒
  GardenVegetableModel copyWithLogsAndReminders({
    List<GardenLog>? logs,
    List<Reminder>? reminders,
  }) {
    return GardenVegetableModel(
      id: id,
      vegetableId: vegetableId,
      vegetableName: vegetableName,
      sowDate: sowDate,
      sunlight: sunlight,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      logs: logs ?? this.logs,
      reminders: reminders ?? this.reminders,
    );
  }
}

List<GardenLog> _logsFromJson(List<dynamic>? json) =>
    json
        ?.map((item) => GardenLogModel.fromJson(item as Map<String, dynamic>))
        .toList() ??
    [];

List<Map<String, dynamic>> _logsToJson(List<GardenLog> logs) =>
    logs.map((log) => GardenLogModel.fromEntity(log).toJson()).toList();

List<Reminder> _remindersFromJson(List<dynamic>? json) =>
    json
        ?.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>))
        .toList() ??
    [];

List<Map<String, dynamic>> _remindersToJson(List<Reminder> reminders) =>
    reminders
        .map((reminder) => ReminderModel.fromEntity(reminder).toJson())
        .toList();
