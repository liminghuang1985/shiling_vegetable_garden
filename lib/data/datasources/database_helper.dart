import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/constants/db_constants.dart';

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
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 迁移映射表：旧版本 -> 迁移处理器列表
    final migrations = <int, List<Future<void> Function(Database)>>{
      // 未来版本示例：
      // 2: [
      //   (db) async { await db.execute('ALTER TABLE vegetables ADD COLUMN new_col TEXT'); },
      // ],
      // 3: [
      //   (db) async { await db.execute('CREATE TABLE new_table (...)'); },
      //   (db) async { await _migrateToV3(db); },
      // ],
    };

    for (int version = oldVersion; version < newVersion; version++) {
      final handlers = migrations[version];
      if (handlers != null) {
        for (final migrate in handlers) {
          await migrate(db);
          print('=== DB migration v$version executed ===');
        }
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
