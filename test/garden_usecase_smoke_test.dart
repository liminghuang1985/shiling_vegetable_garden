// AddVegetableToGarden + GetMyGarden + DeleteGardenVegetable 端到端 smoke.
//
// 不用 SQLite, 纯内存 Repository mock. 验证:
//
//   1. 加菜成功, id 非空, status 默认 growing
//   2. 列表出现刚才加的菜 (按 created_at DESC 排序, 最新的在前)
//   3. 收获 → status 变 harvested
//   4. 删除 → 列表空了
//
// 不覆盖 edge case: 并发 / 空字符串 / 不存在的 id / 数据库错误.
// 仅 smoke, 验证 usecase + entity 装配没问题.

import 'package:flutter_test/flutter_test.dart';

import 'package:shiling_vegetable_garden/core/constants/enums.dart';
import 'package:shiling_vegetable_garden/domain/entities/garden_vegetable.dart';
import 'package:shiling_vegetable_garden/domain/repositories/garden_repository.dart';
import 'package:shiling_vegetable_garden/domain/usecases/garden_usecases.dart';

/// 内存实现 — 只支持 smoke 测试需要的 4 个方法, 其余抛 UnimplementedError.
class _InMemoryGardenRepository implements GardenRepository {
  final Map<String, GardenVegetable> _byId = {};
  final List<String> _creationOrder = []; // 模拟 created_at DESC
  int _seq = 0;

  String _nextId() {
    _seq++;
    return 'g-smoke-$_seq';
  }

  @override
  Future<GardenVegetable> addVegetableToGarden({
    required String vegetableId,
    required String vegetableName,
    required DateTime sowDate,
    BalconyDirection? sunlight,
  }) async {
    final now = DateTime.now();
    final id = _nextId();
    final v = GardenVegetable(
      id: id,
      vegetableId: vegetableId,
      vegetableName: vegetableName,
      sowDate: sowDate,
      sunlight: sunlight,
      status: GardenStatus.growing,
      createdAt: now,
      updatedAt: now,
    );
    _byId[id] = v;
    _creationOrder.add(id);
    return v;
  }

  @override
  Future<List<GardenVegetable>> getAllGardenVegetables() async {
    // 模拟 Datasource 的 ORDER BY created_at DESC — 最新添加的在前.
    return _creationOrder.reversed.map((id) => _byId[id]!).toList();
  }

  @override
  Future<void> deleteGardenVegetable(String id) async {
    _byId.remove(id);
    _creationOrder.remove(id);
  }

  @override
  Future<void> updateGardenVegetableStatus(String id, GardenStatus status) async {
    final existing = _byId[id];
    if (existing == null) return;
    _byId[id] = existing.copyWith(status: status, updatedAt: DateTime.now());
  }

  // -------- smoke 用不到的, 全部抛 UnimplementedError --------
  @override
  Future<List<GardenVegetable>> getGardenVegetablesByStatus(GardenStatus status) =>
      throw UnimplementedError();
  @override
  Future<GardenVegetable?> getGardenVegetableById(String id) =>
      throw UnimplementedError();
  @override
  Future<GardenLog> addGardenLog({
    required String gardenId,
    required String note,
    String? photoPath,
  }) =>
      throw UnimplementedError();
  @override
  Future<List<GardenLog>> getGardenLogs(String gardenId) =>
      throw UnimplementedError();
  @override
  Future<Reminder> addReminder({
    required String gardenId,
    required ReminderType type,
    required DateTime time,
  }) =>
      throw UnimplementedError();
  @override
  Future<List<Reminder>> getReminders(String gardenId) =>
      throw UnimplementedError();
  @override
  Future<void> updateReminderStatus(String reminderId, bool isDone) =>
      throw UnimplementedError();
  @override
  Future<void> deleteReminder(String reminderId) => throw UnimplementedError();
  @override
  Future<void> markOverdueRemindersAsDone() => throw UnimplementedError();
  @override
  Future<void> syncToCloud() => throw UnimplementedError();
  @override
  Future<void> syncFromCloud() => throw UnimplementedError();
}

void main() {
  group('Garden usecase smoke (in-memory repo)', () {
    late GardenRepository repo;
    late AddVegetableToGardenUseCase addUc;
    late GetMyGardenUseCase getUc;
    late UpdateGardenStatusUseCase updateUc;
    late DeleteGardenVegetableUseCase deleteUc;

    setUp(() {
      repo = _InMemoryGardenRepository();
      addUc = AddVegetableToGardenUseCase(repo);
      getUc = GetMyGardenUseCase(repo);
      updateUc = UpdateGardenStatusUseCase(repo);
      deleteUc = DeleteGardenVegetableUseCase(repo);
    });

    test('加菜 → 列表出现 → 收获 → 删除 → 列表空', () async {
      // 1. 初始: 空
      expect(await getUc(), isEmpty);

      // 2. 加菜
      final added = await addUc(
        vegetableId: 'v-tomato',
        vegetableName: '番茄',
        sowDate: DateTime(2026, 3, 15),
        sunlight: BalconyDirection.south,
      );
      expect(added.id, isNotEmpty);
      expect(added.status, GardenStatus.growing);
      expect(added.canHarvest, isTrue);

      // 3. 列表里能看到
      final list1 = await getUc();
      expect(list1, hasLength(1));
      expect(list1.first.vegetableName, '番茄');
      expect(list1.first.sunlight, BalconyDirection.south);

      // 4. 收获 → status 变 harvested → canHarvest = false
      await updateUc.harvest(added.id);
      final list2 = await getUc();
      expect(list2.first.status, GardenStatus.harvested);
      expect(list2.first.canHarvest, isFalse);

      // 5. 删除 → 列表空
      await deleteUc(added.id);
      expect(await getUc(), isEmpty);
    });

    test('加 3 个菜, 列表按 created_at DESC 返回 (最新在前)', () async {
      final a = await addUc(
        vegetableId: 'v-a',
        vegetableName: 'A',
        sowDate: DateTime(2026, 1, 1),
      );
      final b = await addUc(
        vegetableId: 'v-b',
        vegetableName: 'B',
        sowDate: DateTime(2026, 2, 1),
      );
      final c = await addUc(
        vegetableId: 'v-c',
        vegetableName: 'C',
        sowDate: DateTime(2026, 3, 1),
      );

      final list = await getUc();
      expect(list.map((v) => v.id), [c.id, b.id, a.id]);
    });
  });
}
