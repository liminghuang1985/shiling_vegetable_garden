import '../../domain/entities/garden_vegetable.dart';
import '../../core/constants/enums.dart';

/// 生长日志数据模型
class GardenLogModel extends GardenLog {
  const GardenLogModel({
    super.id,
    required super.gardenId,
    required super.date,
    required super.note,
    super.photoPath,
  });

  factory GardenLogModel.fromJson(Map<String, dynamic> json) {
    return GardenLogModel(
      id: json['id'] as int?,
      gardenId: json['garden_id'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
      photoPath: json['photo_path'] as String?,
    );
  }

  factory GardenLogModel.fromMap(Map<String, dynamic> map) {
    return GardenLogModel(
      id: map['id'] as int?,
      gardenId: map['garden_id'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String,
      photoPath: map['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'garden_id': gardenId,
        'date': date.toIso8601String(),
        'note': note,
        'photo_path': photoPath,
      };

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
class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.gardenId,
    required super.type,
    required super.time,
    super.isDone = false,
    super.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      gardenId: json['garden_id'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.water,
      ),
      time: DateTime.parse(json['time'] as String),
      isDone: json['is_done'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'garden_id': gardenId,
        'type': type.name,
        'time': time.toIso8601String(),
        'is_done': isDone,
        'created_at': createdAt?.toIso8601String(),
      };

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

  factory GardenVegetableModel.fromJson(Map<String, dynamic> json) {
    return GardenVegetableModel(
      id: json['id'] as String,
      vegetableId: json['vegetable_id'] as String,
      vegetableName: json['vegetable_name'] as String,
      sowDate: DateTime.parse(json['sow_date'] as String),
      sunlight: json['sunlight'] != null
          ? BalconyDirection.values.firstWhere(
              (e) => e.name == json['sunlight'],
              orElse: () => BalconyDirection.none,
            )
          : null,
      status: GardenStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GardenStatus.growing,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => GardenLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'vegetable_id': vegetableId,
        'vegetable_name': vegetableName,
        'sow_date': sowDate.toIso8601String(),
        'sunlight': sunlight?.name,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'logs': logs
            .map((e) => GardenLogModel.fromEntity(e).toJson())
            .toList(),
        'reminders': reminders
            .map((e) => ReminderModel.fromEntity(e).toJson())
            .toList(),
      };

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
