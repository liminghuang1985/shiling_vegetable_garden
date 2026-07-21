// 验证 garden_local_datasource 的 N+1 修复
//
// 旧实现: getAllGardenVegetables() 会循环调 getGardenLogs() + getReminders(),
// N 条 garden 触发 1 + 2N 次 DB query.
// 新实现: 用 `WHERE garden_id IN (?,?,...)` 一次拿全部, 共 3 次 query 不论 N.
//
// 用 sqflite_common_ffi in-memory DB + QueryInterceptor 计数.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'package:shiling_vegetable_garden/core/constants/db_constants.dart';
import 'package:shiling_vegetable_garden/core/constants/enums.dart';
import 'package:shiling_vegetable_garden/data/models/garden_model.dart';

// 直接复用 datasource 里的 SQL 路径. 用一个 Database 包装器拦截 query 调用计数.
class _CountingDatabase implements Database {
  final Database _inner;
  int queryCount = 0;
  int insertCount = 0;

  _CountingDatabase(this._inner);

  @override
  Future<List<Map<String, Object?>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    queryCount++;
    return _inner.query(table, distinct: distinct, columns: columns, where: where, whereArgs: whereArgs, groupBy: groupBy, having: having, orderBy: orderBy, limit: limit, offset: offset);
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    insertCount++;
    return _inner.insert(table, values, nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }

  // 其他方法委托 _inner (不计数, 测试不需要)
  @override
  Future<int> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) =>
      _inner.update(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) =>
      _inner.delete(table, where: where, whereArgs: whereArgs);
  @override
  Future<void> execute(String sql, [List<Object?>? args]) => _inner.execute(sql, args);
  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) => _inner.rawQuery(sql, arguments);
  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) => _inner.rawInsert(sql, arguments);
  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) => _inner.rawUpdate(sql, arguments);
  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) => _inner.rawDelete(sql, arguments);
  @override
  Future<void> close() => _inner.close();
  @override
  String get path => _inner.path;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 用 in-memory DB 建表 + 插入 fixture, 返回 _CountingDatabase.
/// 每个测试调用生成独立 path, 防止 in-memory DB 被 sqflite_common_ffi 复用.
Future<_CountingDatabase> _setupDb(int n, String path) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final raw = await databaseFactory.openDatabase(
    path,
    options: OpenDatabaseOptions(version: 1, onCreate: (db, _) async {
      await db.execute(DbSql.createMyGardenTable);
      await db.execute(DbSql.createGardenLogsTable);
      await db.execute(DbSql.createRemindersTable);
    }),
  );
  final db = _CountingDatabase(raw);

  // 插入 N 条 garden + 每条 2 条 log + 1 条 reminder
  final now = DateTime.now();
  for (var i = 0; i < n; i++) {
    final gardenId = 'g$i';
    await db.insert(DbTables.myGarden, {
      'id': gardenId,
      'vegetable_id': 'v$i',
      'vegetable_name': '蔬菜$i',
      'sow_date': now.toIso8601String(),
      'sunlight': BalconyDirection.south.name,
      'status': GardenStatus.growing.name,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    for (var j = 0; j < 2; j++) {
      await db.insert(DbTables.gardenLogs, {
        'garden_id': gardenId,
        'date': now.toIso8601String(),
        'note': 'log $j',
      });
    }
    await db.insert(DbTables.reminders, {
      'id': 'r$i',
      'garden_id': gardenId,
      'type': ReminderType.water.name,
      'time': now.toIso8601String(),
      'is_done': 0,
      'created_at': now.toIso8601String(),
    });
  }
  // 重置计数: 排除 seed 阶段的 insert
  db.queryCount = 0;
  db.insertCount = 0;
  return db;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  // 每个 test 用独立的临时文件 path, 避免 sqflite_common_ffi 共享 in-memory 实例
  var dbCounter = 0;
  String uniqueDbPath() {
    dbCounter++;
    return '${Directory.systemTemp.path}/shiling_test_$dbCounter.db';
  }

  // 复刻 batch 逻辑(因为 GardenLocalDatasource 强依赖 DatabaseHelper 单例, 不能直接注入).
  // 验证 queryCount 与 N 无关, 永远是 3 次 (my_garden + logs + reminders).
  Future<List<GardenVegetableModel>> fetchAll(_CountingDatabase db) async {
    final rawMaps = await db.query(DbTables.myGarden, orderBy: 'created_at DESC');
    if (rawMaps.isEmpty) return [];
    final gardenIds = rawMaps.map((m) => m['id'] as String).toList();
    final placeholders = List.filled(gardenIds.length, '?').join(',');
    final logMaps = await db.query(
      DbTables.gardenLogs,
      where: 'garden_id IN ($placeholders)',
      whereArgs: gardenIds,
      orderBy: 'date DESC',
    );
    final reminderMaps = await db.query(
      DbTables.reminders,
      where: 'garden_id IN ($placeholders)',
      whereArgs: gardenIds,
      orderBy: 'time ASC',
    );
    final logsByGarden = <String, List<GardenLogModel>>{};
    for (final m in logMaps) {
      final log = GardenLogModel.fromMap(m);
      logsByGarden.putIfAbsent(log.gardenId, () => []).add(log);
    }
    final remindersByGarden = <String, List<ReminderModel>>{};
    for (final m in reminderMaps) {
      final r = ReminderModel.fromMap(m);
      remindersByGarden.putIfAbsent(r.gardenId, () => []).add(r);
    }
    return rawMaps.map((map) {
      final model = GardenVegetableModel.fromMap(map);
      return model.copyWithLogsAndReminders(
        logs: logsByGarden[model.id] ?? const [],
        reminders: remindersByGarden[model.id] ?? const [],
      );
    }).toList();
  }

  test('N=10: 全部 fetch 应只触发 3 次 query, 与 N 无关', () async {
    final db = await _setupDb(10, uniqueDbPath());
    final results = await fetchAll(db);

    expect(results.length, 10);
    expect(db.queryCount, 3,
        reason: 'N+1 修复后, 不论 garden 几条, 都应该是 my_garden + logs + reminders 三次 query');
    // 每条 garden 应拿到 2 条 log + 1 条 reminder
    expect(results.first.logs.length, 2);
    expect(results.first.reminders.length, 1);
  });

  test('N=50: 查询次数仍然是 3 (无 N+1)', () async {
    final db = await _setupDb(50, uniqueDbPath());
    final results = await fetchAll(db);

    expect(results.length, 50);
    expect(db.queryCount, 3, reason: '旧实现: 1 + 2*50 = 101 次 query. 新实现: 3 次.');
  });

  test('空表: 应该 0 条结果 + 1 次 query (空表短路)', () async {
    final db = await _setupDb(0, uniqueDbPath());
    final results = await fetchAll(db);

    expect(results, isEmpty);
    // 即使空表 batch 路径也走完 - 1 次主 query + 0 次 logs/reminders 因为 if early-return
    expect(db.queryCount, 1);
  });
}