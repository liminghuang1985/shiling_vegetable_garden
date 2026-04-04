import '../entities/garden_vegetable.dart';
import '../../core/constants/enums.dart';

/// 用户菜园仓储接口
abstract class GardenRepository {
  /// 获取用户所有菜园蔬菜
  Future<List<GardenVegetable>> getAllGardenVegetables();

  /// 获取指定状态的菜园蔬菜
  Future<List<GardenVegetable>> getGardenVegetablesByStatus(GardenStatus status);

  /// 获取菜园蔬菜详情
  Future<GardenVegetable?> getGardenVegetableById(String id);

  /// 添加蔬菜到菜园
  Future<GardenVegetable> addVegetableToGarden({
    required String vegetableId,
    required String vegetableName,
    required DateTime sowDate,
    BalconyDirection? sunlight,
  });

  /// 更新菜园蔬菜状态
  Future<void> updateGardenVegetableStatus(String id, GardenStatus status);

  /// 删除菜园蔬菜
  Future<void> deleteGardenVegetable(String id);

  /// 添加生长日志
  Future<GardenLog> addGardenLog({
    required String gardenId,
    required String note,
    String? photoPath,
  });

  /// 获取生长日志
  Future<List<GardenLog>> getGardenLogs(String gardenId);

  /// 添加提醒
  Future<Reminder> addReminder({
    required String gardenId,
    required ReminderType type,
    required DateTime time,
  });

  /// 获取提醒列表
  Future<List<Reminder>> getReminders(String gardenId);

  /// 更新提醒状态
  Future<void> updateReminderStatus(String reminderId, bool isDone);

  /// 删除提醒
  Future<void> deleteReminder(String reminderId);

  /// 标记完成所有到期提醒
  Future<void> markOverdueRemindersAsDone();

  /// 云端同步（预留接口）
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
}
