import '../../domain/entities/garden_vegetable.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../core/constants/enums.dart';
import '../datasources/garden_local_datasource.dart';

/// 用户菜园仓储实现
class GardenRepositoryImpl implements GardenRepository {
  final GardenLocalDatasource _localDatasource;

  GardenRepositoryImpl(this._localDatasource);

  @override
  Future<List<GardenVegetable>> getAllGardenVegetables() async {
    return await _localDatasource.getAllGardenVegetables();
  }

  @override
  Future<List<GardenVegetable>> getGardenVegetablesByStatus(GardenStatus status) async {
    return await _localDatasource.getGardenVegetablesByStatus(status);
  }

  @override
  Future<GardenVegetable?> getGardenVegetableById(String id) async {
    return await _localDatasource.getGardenVegetableById(id);
  }

  @override
  Future<GardenVegetable> addVegetableToGarden({
    required String vegetableId,
    required String vegetableName,
    required DateTime sowDate,
    BalconyDirection? sunlight,
  }) async {
    return await _localDatasource.addVegetableToGarden(
      vegetableId: vegetableId,
      vegetableName: vegetableName,
      sowDate: sowDate,
      sunlight: sunlight,
    );
  }

  @override
  Future<void> updateGardenVegetableStatus(String id, GardenStatus status) async {
    await _localDatasource.updateGardenVegetableStatus(id, status);
  }

  @override
  Future<void> deleteGardenVegetable(String id) async {
    await _localDatasource.deleteGardenVegetable(id);
  }

  @override
  Future<GardenLog> addGardenLog({
    required String gardenId,
    required String note,
    String? photoPath,
  }) async {
    return await _localDatasource.addGardenLog(
      gardenId: gardenId,
      note: note,
      photoPath: photoPath,
    );
  }

  @override
  Future<List<GardenLog>> getGardenLogs(String gardenId) async {
    return await _localDatasource.getGardenLogs(gardenId);
  }

  @override
  Future<Reminder> addReminder({
    required String gardenId,
    required ReminderType type,
    required DateTime time,
  }) async {
    return await _localDatasource.addReminder(
      gardenId: gardenId,
      type: type,
      time: time,
    );
  }

  @override
  Future<List<Reminder>> getReminders(String gardenId) async {
    return await _localDatasource.getReminders(gardenId);
  }

  @override
  Future<void> updateReminderStatus(String reminderId, bool isDone) async {
    await _localDatasource.updateReminderStatus(reminderId, isDone);
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    await _localDatasource.deleteReminder(reminderId);
  }

  @override
  Future<void> markOverdueRemindersAsDone() async {
    await _localDatasource.markOverdueRemindersAsDone();
  }

  @override
  Future<void> syncToCloud() async {
    // TODO: 实现云端同步逻辑
    // 预留接口，待接入云端API后实现
    throw UnimplementedError('云端同步功能待实现');
  }

  @override
  Future<void> syncFromCloud() async {
    // TODO: 实现云端同步逻辑
    // 预留接口，待接入云端API后实现
    throw UnimplementedError('云端同步功能待实现');
  }
}
