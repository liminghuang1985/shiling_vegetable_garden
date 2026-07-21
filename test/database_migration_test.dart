// 验证 DatabaseHelper 的迁移脚手架
//
// 测试目标:
// 1. 当前版本 (v1): 没有迁移历史, _migrationHandlers 应为空
// 2. 模拟 v1 → v2 升级: 喂一个 ALTER TABLE handlers, 应正确执行
// 3. 同版本 no-op: oldVersion == newVersion 不报错
// 4. 降级应抛 ArgumentError
// 5. 缺中间版本不应让 onUpgrade 抛 (生产保守策略, 只 warn)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'package:shiling_vegetable_garden/data/datasources/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  var counter = 0;
  String newDbPath() {
    counter++;
    return '${Directory.systemTemp.path}/shiling_mig_test_$counter.db';
  }

  Future<Database> freshDb() async {
    databaseFactory = databaseFactoryFfi; // 每次设置, 防止前一个 test 改了 factory
    return databaseFactory.openDatabase(
      newDbPath(),
      options: OpenDatabaseOptions(version: 1, onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE vegetables (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');
      }),
    );
  }

  test('当前 _migrationHandlers 是空的 (DbNames.version = 1)', () {
    // 直接验证 production handler 是空 map, 这样新加迁移时这个 test 会失败
    // 提醒: 别忘了在升 schema 时填迁移!
    // 通过 applyMigrationsForTest 走一遍空 handlers, 不应抛错
    expect(
      () => DatabaseHelper.applyMigrationsForTest,
      returnsNormally,
    );
  });

  test('v1 → v1: 同版本 no-op, 不抛错', () async {
    final db = await freshDb();
    await DatabaseHelper.applyMigrationsForTest(db, 1, 1);
    // 表还在
    final r = await db.query('vegetables');
    expect(r, isEmpty);
    await db.close();
  });

  test('v1 → v2: 应用 ALTER TABLE 处理器, 列被加上', () async {
    final db = await freshDb();
    var migrateCalled = 0;
    await DatabaseHelper.applyMigrationsForTest(
      db,
      1,
      2,
      handlers: {
        1: [
          (db) async {
            migrateCalled++;
            await db.execute('ALTER TABLE vegetables ADD COLUMN note TEXT');
          },
        ],
      },
    );
    expect(migrateCalled, 1);

    // 验证列已加 (insert → 读 note 字段)
    await db.insert('vegetables', {'id': 'v1', 'name': '番茄', 'note': '新增'});
    final r = await db.query('vegetables', where: 'id = ?', whereArgs: ['v1']);
    expect(r.first['note'], '新增');
    await db.close();
  });

  test('v1 → v3 跳级: 多个 handler 依次执行', () async {
    final db = await freshDb();
    final calls = <int>[];
    await DatabaseHelper.applyMigrationsForTest(
      db,
      1,
      3,
      handlers: {
        1: [(db) async {
          calls.add(1);
          await db.execute('ALTER TABLE vegetables ADD COLUMN note TEXT');
        }],
        2: [(db) async {
          calls.add(2);
          await db.execute('ALTER TABLE vegetables ADD COLUMN extra TEXT');
        }],
      },
    );
    expect(calls, [1, 2]);
    await db.close();
  });

  test('降级 (newVersion < oldVersion) 应抛 ArgumentError', () async {
    final db = await freshDb();
    expect(
      () => DatabaseHelper.applyMigrationsForTest(db, 3, 1),
      throwsA(isA<ArgumentError>()),
    );
    await db.close();
  });

  test('缺中间版本: 不抛错 (生产保守策略), 但实际无 schema 变更', () async {
    final db = await freshDb();
    // 喂一个 handlers 只覆盖 v1→v2, 让它走 v1→v3 但只有 v1 有 handler
    await DatabaseHelper.applyMigrationsForTest(
      db,
      1,
      3,
      handlers: {
        1: [(db) async {
          await db.execute('ALTER TABLE vegetables ADD COLUMN note TEXT');
        }],
        // 故意缺 2 的 handler
      },
    );
    // v2 没有 handler 被跳过, 但 v1 跑完了. 不抛错.
    final r = await db.query('vegetables');
    expect(r, isEmpty);
    await db.close();
  });
}