import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/constants/db_constants.dart';
import '../../core/utils/logger.dart';

/// 数据库初始化和辅助类
class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  /// 获取数据库实例（单例）
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    // 桌面端使用 FFI
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, DbNames.main);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: DbNames.version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建城市表
    await db.execute(DbSql.createCitiesTable);

    // 创建蔬菜表
    await db.execute(DbSql.createVegetablesTable);

    // 创建种植日历表
    await db.execute(DbSql.createPlantingCalendarTable);

    // 创建用户菜园表
    await db.execute(DbSql.createMyGardenTable);

    // 创建生长日志表
    await db.execute(DbSql.createGardenLogsTable);

    // 创建提醒表
    await db.execute(DbSql.createRemindersTable);

    // 创建索引
    final indexStatements = DbSql.createIndexes.split(';');
    for (final statement in indexStatements) {
      final trimmed = statement.trim();
      if (trimmed.isNotEmpty) {
        await db.execute(trimmed);
      }
    }
  }

  /// 升级数据库
  /// T7: 填实迁移脚手架. 任何 schema 变更必须在此处加迁移逻辑.
  /// 当前 DbNames.version=1, 无迁移历史.
  /// 升级示例: 升 v2 时, 加 `2: [(db) async { await db.execute('ALTER TABLE ...'); }]`
  ///
  /// ⚠️ 老用户升级路径: openDatabase 检测到 version 变化 → 调 _onUpgrade
  /// 如果这个 map 漏了对应版本, 用户启动崩溃. 永远不要跳过这一步.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _applyMigrations(db, oldVersion, newVersion, _migrationHandlers);
  }

  /// 迁移处理函数集合 (oldVersion → handlers)
  /// 例: 升 v2 加 column, 升 v3 加表, 等等.
  /// 列出此字段的 key 必须连续 (2,3,4,... 不能跳).
  static final Map<int, List<Future<void> Function(Database)>> _migrationHandlers = {
    // ===== 模板: 升 v2 时填这里 =====
    // 2: [
    //   (db) async {
    //     await db.execute('ALTER TABLE vegetables ADD COLUMN new_field TEXT');
    //   },
    // ],
    // ===== 模板结束 =====
  };

  /// 抽取出来的纯函数, 方便单元测试直接喂 _migrationHandlers 进来验证
  /// 不会因为没新版本而误判 (旧版 → 同版本 no-op).
  /// (不用 @visibleForTesting 因为 meta 包没直接依赖, ignore 也不优雅.)
  static Future<void> applyMigrationsForTest(
    Database db,
    int oldVersion,
    int newVersion, {
    Map<int, List<Future<void> Function(Database)>>? handlers,
  }) =>
      _applyMigrations(
        db,
        oldVersion,
        newVersion,
        handlers ?? _migrationHandlers,
      );

  static Future<void> _applyMigrations(
    Database db,
    int oldVersion,
    int newVersion,
    Map<int, List<Future<void> Function(Database)>> handlers,
  ) async {
    if (newVersion < oldVersion) {
      throw ArgumentError(
        'newVersion ($newVersion) must be >= oldVersion ($oldVersion). '
        '不允许降级 schema.',
      );
    }
    if (newVersion == oldVersion) {
      // 同版本 no-op. 新装用户走 _onCreate, 不走这里.
      return;
    }

    // 检测连续性: 不能有空洞 (漏一个版本会让中间用户崩溃)
    for (int v = oldVersion; v < newVersion; v++) {
      if (!handlers.containsKey(v)) {
        AppLogger.w(
          'No migration handler for v$v → v${v + 1}. '
          '老用户从 v$v 升上来会崩溃!',
        );
        // ⚠️ 选择 1: 抛错让启动失败 (开发期可见)
        // ⚠️ 选择 2: 不抛, 让 onUpgrade 至少成功 (生产环境保守)
        // 当前选 2 (保守), 但日志留痕方便诊断. 想严格请改 throw.
      }
    }

    for (int version = oldVersion; version < newVersion; version++) {
      final versionHandlers = handlers[version];
      if (versionHandlers == null) continue;
      for (final migrate in versionHandlers) {
        await migrate(db);
        AppLogger.i('DB migration v$version executed');
      }
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// 清空所有数据（仅用于测试）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(DbTables.reminders);
    await db.delete(DbTables.gardenLogs);
    await db.delete(DbTables.myGarden);
    await db.delete(DbTables.plantingCalendar);
    await db.delete(DbTables.vegetables);
    await db.delete(DbTables.cities);
  }

  /// 检查数据库是否为空（未初始化）
  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final result = await db.query(DbTables.vegetables, limit: 1);
    return result.isEmpty;
  }
}
