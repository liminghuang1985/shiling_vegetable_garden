import '../../domain/entities/garden_vegetable.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../core/constants/enums.dart';
import '../datasources/hive_datasource.dart';

class GardenRepositoryImpl implements GardenRepository {
  @override
  Future<List<GardenVegetable>> getAllGardenVegetables() async => HiveDataSource.getAllGardenVegetables();

  @override
  Future<List<GardenVegetable>> getGardenVegetablesByStatus(GardenStatus status) async {
    final all = HiveDataSource.getAllGardenVegetables();
    return all.where((gv) => gv.status == status).toList();
  }

  @override
  Future<GardenVegetable?> getGardenVegetableById(String id) async => HiveDataSource.getGardenVegetableById(id);

  @override
  Future<GardenVegetable> addVegetableToGarden({
    required String vegetableId, required String vegetableName,
    required DateTime sowDate, BalconyDirection? sunlight,
  }) async => HiveDataSource.addVegetableToGarden(
    vegetableId: vegetableId, vegetableName: vegetableName,
    sowDate: sowDate, sunlight: sunlight,
  );

  @override
  Future<void> updateGardenVegetableStatus(String id, GardenStatus status) async => HiveDataSource.updateGardenStatus(id, status);

  @override
  Future<void> deleteGardenVegetable(String id) async => HiveDataSource.deleteGardenVegetable(id);

  @override
  Future<GardenLog> addGardenLog({required String gardenId, required String note, String? photoPath}) async {
    return GardenLog(gardenId: gardenId, date: DateTime.now(), note: note, photoPath: photoPath);
  }

  @override
  Future<List<GardenLog>> getGardenLogs(String gardenId) async => [];

  @override
  Future<Reminder> addReminder({required String gardenId, required ReminderType type, required DateTime time}) async {
    return Reminder(id: DateTime.now().millisecondsSinceEpoch.toString(), gardenId: gardenId, type: type, time: time, isDone: false);
  }

  @override
  Future<List<Reminder>> getReminders(String gardenId) async => [];
  @override
  Future<void> updateReminderStatus(String reminderId, bool isDone) async {}
  @override
  Future<void> deleteReminder(String reminderId) async {}
  @override
  Future<void> markOverdueRemindersAsDone() async {}
  @override
  Future<void> syncToCloud() async {}
  @override
  Future<void> syncFromCloud() async {}
}
