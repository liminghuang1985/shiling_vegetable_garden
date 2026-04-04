import '../../core/constants/enums.dart';

/// 生长日志
class GardenLog {
  final int? id;
  final String gardenId;
  final DateTime date;
  final String note;
  final String? photoPath;

  const GardenLog({
    this.id,
    required this.gardenId,
    required this.date,
    required this.note,
    this.photoPath,
  });

  GardenLog copyWith({
    int? id,
    String? gardenId,
    DateTime? date,
    String? note,
    String? photoPath,
  }) {
    return GardenLog(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      date: date ?? this.date,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  String toString() => 'GardenLog(id: $id, gardenId: $gardenId, date: $date, note: $note)';
}

/// 提醒
class Reminder {
  final String id;
  final String gardenId;
  final ReminderType type;
  final DateTime time;
  final bool isDone;
  final DateTime? createdAt;

  const Reminder({
    required this.id,
    required this.gardenId,
    required this.type,
    required this.time,
    this.isDone = false,
    this.createdAt,
  });

  Reminder copyWith({
    String? id,
    String? gardenId,
    ReminderType? type,
    DateTime? time,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      type: type ?? this.type,
      time: time ?? this.time,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Reminder(id: $id, gardenId: $gardenId, type: ${type.label}, time: $time, isDone: $isDone)';
}

/// 用户菜园中的蔬菜
class GardenVegetable {
  final String id;
  final String vegetableId;
  final String vegetableName;
  final DateTime sowDate;
  final BalconyDirection? sunlight;
  final GardenStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<GardenLog> logs;
  final List<Reminder> reminders;

  const GardenVegetable({
    required this.id,
    required this.vegetableId,
    required this.vegetableName,
    required this.sowDate,
    this.sunlight,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.logs = const [],
    this.reminders = const [],
  });

  /// 计算种植天数
  int get daysSinceSow => DateTime.now().difference(sowDate).inDays;

  /// 是否可以收获
  bool get canHarvest => status == GardenStatus.growing;

  GardenVegetable copyWith({
    String? id,
    String? vegetableId,
    String? vegetableName,
    DateTime? sowDate,
    BalconyDirection? sunlight,
    GardenStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GardenLog>? logs,
    List<Reminder>? reminders,
  }) {
    return GardenVegetable(
      id: id ?? this.id,
      vegetableId: vegetableId ?? this.vegetableId,
      vegetableName: vegetableName ?? this.vegetableName,
      sowDate: sowDate ?? this.sowDate,
      sunlight: sunlight ?? this.sunlight,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      logs: logs ?? this.logs,
      reminders: reminders ?? this.reminders,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GardenVegetable && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GardenVegetable(id: $id, vegetableName: $vegetableName, status: ${status.label}, sowDate: $sowDate)';
}
