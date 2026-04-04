# 时令菜园 - 数据模型设计文档

> 版本：v1.0
> 日期：2026-04-04
> 状态：✅ 模型已定义，Builder 已实现

---

## 一、数据库概览

| 表名 | 用途 | 备注 |
|------|------|------|
| `cities` | 城市-气候带映射 | 预置数据，约300条 |
| `vegetables` | 蔬菜详情 | 预置数据，60条 |
| `planting_calendar` | 种植日历 | 气候带×月份→蔬菜列表 |
| `my_garden` | 用户菜园 | 用户数据 |
| `garden_logs` | 生长日志 | 关联 my_garden |
| `reminders` | 种植提醒 | 关联 my_garden |

---

## 二、数据模型定义

### 2.1 气候带枚举（ClimateZone）

```
cold       → 寒温带（东北）
temperate  → 中温带（华北北部）
warm       → 暖温带（华北南部/西北）
subtropical → 亚热带（华中/华东）
tropical  → 热带（华南）
plateau   → 高原气候（云南/西藏/青海）
```

### 2.2 蔬菜分类（VegetableCategory）

```
leafy  → 叶菜类（小白菜、菠菜、生菜...）
fruit  → 果菜类（番茄、黄瓜、茄子...）
root   → 根茎类（萝卜、胡萝卜、红薯...）
legume → 豆类（四季豆、豌豆、毛豆...）
herb   → 香草类（香菜、薄荷、紫苏...）
```

### 2.3 光照需求（SunlightNeed）

```
fullSun    → 喜阳（需要充足阳光）
partialSun → 喜阴/耐阴（半日照）
shade      → 耐阴（弱光环境）
```

### 2.4 土壤要求（SoilRequirement）

| 字段 | 类型 | 说明 |
|------|------|------|
| type | String | 土壤类型描述，如"疏松肥沃" |
| phMin | double | 最低 pH 值 |
| phMax | double | 最高 pH 值 |
| drainage | String | 排水性，如"良好"/"一般" |

### 2.5 肥料信息（FertilizerInfo）

| 字段 | 类型 | 说明 |
|------|------|------|
| base | String | 基肥建议 |
| top | String | 追肥建议 |

### 2.6 种植信息（PlantingInfo）

| 字段 | 类型 | 说明 |
|------|------|------|
| depthCm | int | 播种深度（cm） |
| spacingCm | int | 株距（cm） |
| rowSpacingCm | int | 行距（cm） |
| germinationDays | int | 发芽天数 |
| maturityDays | int | 成熟天数（从播种到采收） |

### 2.7 蔬菜详情（Vegetable）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | 唯一标识（中文拼音缩写，如"fq"） |
| name | String | 蔬菜名称，如"番茄" |
| alias | String | 别名，如"西红柿" |
| category | VegetableCategory | 分类 |
| sunlight | SunlightNeed | 光照需求 |
| minTemp | double | 最低生长温度（℃） |
| maxTemp | double | 最高生长温度（℃） |
| soil | SoilRequirement | 土壤要求 |
| fertilizer | FertilizerInfo | 肥料建议 |
| planting | PlantingInfo | 种植信息 |
| nutrients | List<String> | 主要营养成分 |
| cautions | List<String> | 注意事项/常见问题 |
| suitableClimates | List<ClimateZone> | 适合的气候带 |

### 2.8 城市（City）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 自增主键 |
| name | String | 城市名称，如"北京" |
| province | String | 所属省份，如"北京" |
| climateZone | ClimateZone | 所属气候带 |

### 2.9 种植日历（PlantingCalendar）

存储结构：气候带 × 月份 → 蔬菜ID列表

```
Map<ClimateZone, Map<int, List<String>>>
// 例: subtropical[4月] → ["fq", "hg", "lj", "qz", "xlb", "yc"...]
```

### 2.10 用户菜园（MyGarden / GardenVegetable）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | UUID，唯一标识 |
| vegetableId | String | 关联蔬菜ID |
| vegetableName | String | 蔬菜名称（冗余存储） |
| sowDate | DateTime | 播种日期 |
| sunlight | String | 用户阳台朝向（east/south/west/north） |
| status | GardenStatus | growing（生长中）/ harvested（已采收）/ cancelled（已取消） |

### 2.11 生长日志（GardenLog）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | UUID |
| gardenId | String | 关联 GardenVegetable |
| date | DateTime | 记录日期 |
| note | String | 记录内容 |
| photoPath | String? | 照片路径（本地） |

### 2.12 种植提醒（Reminder）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | UUID |
| gardenId | String | 关联 GardenVegetable |
| type | ReminderType | water（浇水）/ fertilize（施肥）/ harvest（采收） |
| time | DateTime | 提醒时间 |
| isDone | bool | 是否已完成 |

---

## 三、ER 关系图

```
┌─────────────┐     ┌──────────────────┐
│   cities    │────→│  City.climateZone │
└─────────────┘     └──────────────────┘
                            ↓
                     ┌──────────────────┐
                     │ planting_calendar │ (气候带×月份→蔬菜)
                     └──────────────────┘
                            ↓
┌─────────────┐     ┌──────────────────┐
│ my_garden   │────→│   vegetables     │
│ (用户菜园)   │     │   (蔬菜详情)      │
└─────────────┘     └──────────────────┘
       ↓
       ├────→ garden_logs (生长日志)
       └────→ reminders (种植提醒)
```

---

## 四、SQLite 建表语句

### cities 表
```sql
CREATE TABLE cities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  province TEXT NOT NULL,
  climate_zone TEXT NOT NULL
);
```

### vegetables 表
```sql
CREATE TABLE vegetables (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  alias TEXT,
  category TEXT NOT NULL,
  sunlight TEXT NOT NULL,
  min_temp REAL,
  max_temp REAL,
  soil_type TEXT,
  soil_ph_min REAL,
  soil_ph_max REAL,
  soil_drainage TEXT,
  fertilizer_base TEXT,
  fertilizer_top TEXT,
  planting_depth INTEGER,
  planting_spacing INTEGER,
  planting_row_spacing INTEGER,
  planting_germination_days INTEGER,
  planting_maturity_days INTEGER,
  nutrients TEXT,
  cautions TEXT,
  suitable_climates TEXT
);
```

### planting_calendar 表
```sql
CREATE TABLE planting_calendar (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  climate_zone TEXT NOT NULL,
  month INTEGER NOT NULL,
  vegetable_ids TEXT NOT NULL,
  UNIQUE(climate_zone, month)
);
```

### my_garden 表
```sql
CREATE TABLE my_garden (
  id TEXT PRIMARY KEY,
  vegetable_id TEXT NOT NULL,
  vegetable_name TEXT NOT NULL,
  sow_date TEXT NOT NULL,
  sunlight TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'growing',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### garden_logs 表
```sql
CREATE TABLE garden_logs (
  id TEXT PRIMARY KEY,
  garden_id TEXT NOT NULL,
  date TEXT NOT NULL,
  note TEXT,
  photo_path TEXT,
  FOREIGN KEY (garden_id) REFERENCES my_garden(id)
);
```

### reminders 表
```sql
CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  garden_id TEXT NOT NULL,
  type TEXT NOT NULL,
  time TEXT NOT NULL,
  is_done INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (garden_id) REFERENCES my_garden(id)
);
```

---

## 五、JSON 数据格式

### vegetables.json（预置蔬菜数据）
```json
[
  {
    "id": "fq",
    "name": "番茄",
    "alias": "西红柿",
    "category": "fruit",
    "sunlight": "fullSun",
    "minTemp": 15,
    "maxTemp": 35,
    "soil": {
      "type": "疏松肥沃",
      "phMin": 6.0,
      "phMax": 7.0,
      "drainage": "良好"
    },
    "fertilizer": {
      "base": "腐熟有机肥",
      "top": "结果期追施磷钾肥"
    },
    "planting": {
      "depthCm": 1,
      "spacingCm": 40,
      "rowSpacingCm": 60,
      "germinationDays": 7,
      "maturityDays": 90
    },
    "nutrients": ["维生素C", "番茄红素", "钾"],
    "cautions": ["不耐连作", "注意防治晚疫病"],
    "suitableClimates": ["warm", "subtropical", "tropical"]
  }
]
```

### cities.json（城市-气候带映射）
```json
[
  { "id": 1, "name": "北京", "province": "北京", "climateZone": "temperate" },
  { "id": 2, "name": "上海", "province": "上海", "climateZone": "subtropical" }
]
```

### planting_calendar.json（种植日历）
```json
[
  {
    "climateZone": "subtropical",
    "calendar": {
      "1": ["cc", "sc", "lb", "wd"],
      "2": ["cc", "sc", "lb", "wd", "qc"],
      ...
    }
  }
]
```

---

## 六、字段映射规则

### JSON → SQLite

| JSON 字段 | SQLite 列 | 转换说明 |
|---------|----------|---------|
| nutrients (List) | nutrients (TEXT) | JSON.stringify → 存文本 |
| cautions (List) | cautions (TEXT) | JSON.stringify → 存文本 |
| suitableClimates (List) | suitable_climates (TEXT) | JSON.stringify → 存文本 |
| soil (Object) | soil_type, soil_ph_min... | 展开为独立列 |
| fertilizer (Object) | fertilizer_base, fertilizer_top | 展开为独立列 |
| planting (Object) | planting_depth... | 展开为独立列 |
| climateZone (Enum) | climate_zone (TEXT) | Enum.toString() |

---

## 七、预留云端同步接口

```dart
abstract class IVegetableRepository {
  // 获取蔬菜列表
  Future<List<Vegetable>> getAll();

  // 按分类筛选
  Future<List<Vegetable>> getByCategory(VegetableCategory category);

  // 按气候带+月份获取时令蔬菜
  Future<List<Vegetable>> getBySeason(ClimateZone zone, int month);

  // 搜索蔬菜
  Future<List<Vegetable>> search(String keyword);

  // 云端更新（预留）
  Future<void> syncFromCloud();
}

abstract class ICityRepository {
  // 获取城市列表
  Future<List<City>> getAll();

  // 搜索城市
  Future<List<City>> search(String keyword);

  // 云端更新（预留）
  Future<void> syncFromCloud();
}
```
