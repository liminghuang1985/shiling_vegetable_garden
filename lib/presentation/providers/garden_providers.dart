import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/garden_vegetable.dart';
import '../../core/constants/enums.dart';
import 'core_providers.dart';

/// ========== 菜园列表 Provider ==========

/// 所有菜园蔬菜
final myGardenProvider = FutureProvider<List<GardenVegetable>>((ref) async {
  final useCase = ref.watch(getMyGardenUseCaseProvider);
  return useCase();
});

/// 生长中的蔬菜
final growingGardenProvider = FutureProvider<List<GardenVegetable>>((ref) async {
  final useCase = ref.watch(getMyGardenUseCaseProvider);
  return useCase.getGrowing();
});

/// 按状态筛选的菜园蔬菜
final gardenByStatusProvider = FutureProvider.family<List<GardenVegetable>, GardenStatus>((ref, status) async {
  final useCase = ref.watch(getMyGardenUseCaseProvider);
  return useCase.byStatus(status);
});

/// ========== 单个菜园蔬菜 Provider ==========

/// 菜园蔬菜详情
final gardenVegetableDetailsProvider = FutureProvider.family<GardenVegetable?, String>((ref, id) async {
  final repository = ref.watch(gardenRepositoryProvider);
  return repository.getGardenVegetableById(id);
});

/// ========== 菜园操作 Provider（用于触发刷新）==========

/// 菜园操作通知器
class GardenNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  GardenNotifier(this._ref) : super(const AsyncValue.data(null));

  /// 添加蔬菜到菜园
  Future<void> addVegetable({
    required String vegetableId,
    required String vegetableName,
    required DateTime sowDate,
    BalconyDirection? sunlight,
  }) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(addVegetableToGardenUseCaseProvider);
      await useCase(
        vegetableId: vegetableId,
        vegetableName: vegetableName,
        sowDate: sowDate,
        sunlight: sunlight,
      );
      state = const AsyncValue.data(null);
      // 通知刷新
      _ref.invalidate(myGardenProvider);
      _ref.invalidate(growingGardenProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 更新状态（收获/取消）
  Future<void> updateStatus(String gardenId, GardenStatus status) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(updateGardenStatusUseCaseProvider);
      await useCase(gardenId, status);
      state = const AsyncValue.data(null);
      _ref.invalidate(myGardenProvider);
      _ref.invalidate(growingGardenProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 收获
  Future<void> harvest(String gardenId) async {
    await updateStatus(gardenId, GardenStatus.harvested);
  }

  /// 取消
  Future<void> cancel(String gardenId) async {
    await updateStatus(gardenId, GardenStatus.cancelled);
  }

  /// 删除
  Future<void> delete(String gardenId) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(deleteGardenVegetableUseCaseProvider);
      await useCase(gardenId);
      state = const AsyncValue.data(null);
      _ref.invalidate(myGardenProvider);
      _ref.invalidate(growingGardenProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 添加生长日志
  Future<bool> addLog({
    required String gardenId,
    required String note,
    String? photoPath,
  }) async {
    try {
      final useCase = _ref.read(manageGardenLogsUseCaseProvider);
      await useCase.add(gardenId: gardenId, note: note, photoPath: photoPath);
      _ref.invalidate(gardenVegetableDetailsProvider(gardenId));
      _ref.invalidate(myGardenProvider);
      return true;
    } catch (e) {
      // TODO(UI层): 监听 gardenNotifierProvider 状态，失败时显示 Snackbar
      return false;
    }
  }

  /// 添加提醒
  Future<bool> addReminder({
    required String gardenId,
    required ReminderType type,
    required DateTime time,
  }) async {
    try {
      final useCase = _ref.read(manageRemindersUseCaseProvider);
      await useCase.add(gardenId: gardenId, type: type, time: time);
      _ref.invalidate(gardenVegetableDetailsProvider(gardenId));
      return true;
    } catch (e) {
      // TODO(UI层): 监听 gardenNotifierProvider 状态，失败时显示 Snackbar
      return false;
    }
  }

  /// 标记提醒完成
  Future<bool> markReminderDone(String reminderId) async {
    try {
      final useCase = _ref.read(manageRemindersUseCaseProvider);
      await useCase.markDone(reminderId);
      _ref.invalidate(myGardenProvider);
      return true;
    } catch (e) {
      // TODO(UI层): 监听 gardenNotifierProvider 状态，失败时显示 Snackbar
      return false;
    }
  }

  /// 删除提醒
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final useCase = _ref.read(manageRemindersUseCaseProvider);
      await useCase.delete(reminderId);
      _ref.invalidate(myGardenProvider);
      return true;
    } catch (e) {
      // TODO(UI层): 监听 gardenNotifierProvider 状态，失败时显示 Snackbar
      return false;
    }
  }
}

/// 菜园操作通知器 Provider
final gardenNotifierProvider = StateNotifierProvider<GardenNotifier, AsyncValue<void>>((ref) {
  return GardenNotifier(ref);
});
