/// 数据库表名常量
class DbTables {
  static const String cities = 'cities';
  static const String vegetables = 'vegetables';
  static const String plantingCalendar = 'planting_calendar';
  static const String myGarden = 'my_garden';
  static const String gardenLogs = 'garden_logs';
  static const String reminders = 'reminders';
}

/// 数据库名称
class DbNames {
  static const String main = 'shiling_vegetable_garden.db';
  static const int version = 1;
}

/// SQLite 建表语句
class DbSql {
  /// 城市表 - 城市-气候带映射
  static const String createCitiesTable = '''
    CREATE TABLE ${DbTables.cities} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      province TEXT NOT NULL,
      climate_zone TEXT NOT NULL
    )
  ''';

  /// 蔬菜表 - 蔬菜数据库
  static const String createVegetablesTable = '''
    CREATE TABLE ${DbTables.vegetables} (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      alias TEXT,
      category TEXT NOT NULL,
      sunlight TEXT NOT NULL,
      min_temp REAL NOT NULL,
      max_temp REAL NOT NULL,
      soil_type TEXT,
      soil_ph_min REAL,
      soil_ph_max REAL,
      soil_drainage TEXT,
      fertilizer_base TEXT,
      fertilizer_top TEXT,
      planting_depth INTEGER,
      planting_spacing INTEGER,
      planting_row_spacing INTEGER,
      germination_days INTEGER,
      maturity_days INTEGER,
      nutrients TEXT,
      cautions TEXT,
      suitable_climates TEXT
    )
  ''';

  /// 种植日历表 - 气候带+月份 -> 可种蔬菜列表
  static const String createPlantingCalendarTable = '''
    CREATE TABLE ${DbTables.plantingCalendar} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      climate_zone TEXT NOT NULL,
      month INTEGER NOT NULL,
      vegetable_ids TEXT NOT NULL
    )
  ''';

  /// 用户菜园表 - 我的菜园
  static const String createMyGardenTable = '''
    CREATE TABLE ${DbTables.myGarden} (
      id TEXT PRIMARY KEY,
      vegetable_id TEXT NOT NULL,
      vegetable_name TEXT NOT NULL,
      sow_date TEXT NOT NULL,
      sunlight TEXT,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  /// 生长日志表
  static const String createGardenLogsTable = '''
    CREATE TABLE ${DbTables.gardenLogs} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      garden_id TEXT NOT NULL,
      date TEXT NOT NULL,
      note TEXT NOT NULL,
      photo_path TEXT,
      FOREIGN KEY (garden_id) REFERENCES ${DbTables.myGarden}(id) ON DELETE CASCADE
    )
  ''';

  /// 提醒表
  static const String createRemindersTable = '''
    CREATE TABLE ${DbTables.reminders} (
      id TEXT PRIMARY KEY,
      garden_id TEXT NOT NULL,
      type TEXT NOT NULL,
      time TEXT NOT NULL,
      is_done INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (garden_id) REFERENCES ${DbTables.myGarden}(id) ON DELETE CASCADE
    )
  ''';

  /// 创建索引
  static const String createIndexes = '''
    CREATE INDEX idx_cities_climate ON ${DbTables.cities}(climate_zone);
    CREATE INDEX idx_vegetables_category ON ${DbTables.vegetables}(category);
    CREATE INDEX idx_planting_calendar_climate ON ${DbTables.plantingCalendar}(climate_zone, month);
    CREATE INDEX idx_my_garden_vegetable ON ${DbTables.myGarden}(vegetable_id);
    CREATE INDEX idx_my_garden_status ON ${DbTables.myGarden}(status);
    CREATE INDEX idx_garden_logs_garden ON ${DbTables.gardenLogs}(garden_id);
    CREATE INDEX idx_reminders_garden ON ${DbTables.reminders}(garden_id);
  ''';
}
