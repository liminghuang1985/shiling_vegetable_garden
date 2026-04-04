import '../entities/garden_vegetable.dart';
import '../repositories/garden_repository.dart';
import '../../core/constants/enums.dart';

/// 添加蔬菜到菜园用例
class AddVegetableToGardenUseCase {
  final GardenRepository _repository;

  AddVegetableToGardenUseCase(this._repository);

  Future<GardenVegetable> call({
    required String vegetableId,
    required String vegetableName,
    required DateTime sowDate,
    BalconyDirection? sunlight,
  }) {
    return _repository.addVegetableToGarden(
      vegetableId: vegetableId,
      vegetableName: vegetableName,
      sowDate: sowDate,
      sunlight: sunlight,
    );
  }
}

/// 获取我的菜园用例
class GetMyGardenUseCase {
  final GardenRepository _repository;

  GetMyGardenUseCase(this._repository);

  /// 获取所有菜园蔬菜
  Future<List<GardenVegetable>> call() {
    return _repository.getAllGardenVegetables();
  }

  /// 获取指定状态的菜园蔬菜
  Future<List<GardenVegetable>> byStatus(GardenStatus status) {
    return _repository.getGardenVegetablesByStatus(status);
  }

  /// 获取生长中的蔬菜
  Future<List<GardenVegetable>> getGrowing() {
    return _repository.getGardenVegetablesByStatus(GardenStatus.growing);
  }
}

/// 更新菜园状态用例
class UpdateGardenStatusUseCase {
  final GardenRepository _repository;

  UpdateGardenStatusUseCase(this._repository);

  Future<void> call(String gardenId, GardenStatus status) {
    return _repository.updateGardenVegetableStatus(gardenId, status);
  }

  /// 收获蔬菜
  Future<void> harvest(String gardenId) {
    return _repository.updateGardenVegetableStatus(gardenId, GardenStatus.harvested);
  }

  /// 取消种植
  Future<void> cancel(String gardenId) {
    return _repository.updateGardenVegetableStatus(gardenId, GardenStatus.cancelled);
  }
}

/// 删除菜园蔬菜用例
class DeleteGardenVegetableUseCase {
  final GardenRepository _repository;

  DeleteGardenVegetableUseCase(this._repository);

  Future<void> call(String gardenId) {
    return _repository.deleteGardenVegetable(gardenId);
  }
}

/// 生长日志用例
class ManageGardenLogsUseCase {
  final GardenRepository _repository;

  ManageGardenLogsUseCase(this._repository);

  /// 添加日志
  Future<GardenLog> add({
    required String gardenId,
    required String note,
    String? photoPath,
  }) {
    return _repository.addGardenLog(
      gardenId: gardenId,
      note: note,
      photoPath: photoPath,
    );
  }

  /// 获取日志列表
  Future<List<GardenLog>> getLogs(String gardenId) {
    return _repository.getGardenLogs(gardenId);
  }
}

/// 提醒管理用例
class ManageRemindersUseCase {
  final GardenRepository _repository;

  ManageRemindersUseCase(this._repository);

  /// 添加提醒
  Future<Reminder> add({
    required String gardenId,
    required ReminderType type,
    required DateTime time,
  }) {
    return _repository.addReminder(
      gardenId: gardenId,
      type: type,
      time: time,
    );
  }

  /// 获取提醒列表
  Future<List<Reminder>> getReminders(String gardenId) {
    return _repository.getReminders(gardenId);
  }

  /// 标记提醒完成
  Future<void> markDone(String reminderId) {
    return _repository.updateReminderStatus(reminderId, true);
  }

  /// 删除提醒
  Future<void> delete(String reminderId) {
    return _repository.deleteReminder(reminderId);
  }
}
