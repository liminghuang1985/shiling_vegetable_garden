# 时令菜园 (Shiling Vegetable Garden)

> 基于中国气候带的时令蔬菜种植指南 App. Flutter 5 端 (Android / iOS / Web / macOS / Windows).

## 项目一句话定位

为阳台 / 小菜园用户提供**按气候带过滤的蔬菜推荐 + 种植日历 + 我的菜园管理 + 病虫害识别**的离线 App.

**作者**: 黄黎明 (`liminghuang1985`). 个人项目, 已发 APK v2 (77.6MB).

## 技术栈 (设计选择, 不要改)

| 维度 | 选型 | 备注 |
|---|---|---|
| 跨端 | Flutter 3.11+ | Android / iOS / Web / macOS / Windows |
| 状态管理 | Riverpod 2.6 | `flutter_riverpod`, Provider 拓扑见 `lib/presentation/providers/` |
| 本地存储 | sqflite + shared_preferences | 5 端唯一可用方案. 桌面端用 `sqflite_common_ffi` |
| 架构 | Clean Architecture | `domain` / `data` / `presentation` 三层 |
| JSON | 手写 `fromJson` (迁移中) | pubspec 已装 `json_serializable` 但**未启用**, 逐步替换中 |
| 通知 | flutter_local_notifications (未启用) | pubspec 引了但实际没集成, 别删 |

## 目录结构

```
lib/
├── core/                  # 跨层基础设施 (不依赖 domain / data / presentation)
│   ├── constants/         # AppConstants / DbNames / DbSql / DbTables / enums
│   ├── theme/             # 颜色 / 字号 / 间距
│   └── utils/             # date_utils 等通用工具
├── domain/                # 业务抽象 (零外部依赖)
│   ├── entities/          # 纯 Dart 实体 (Vegetable / City / GardenVegetable / ...)
│   ├── repositories/      # 抽象接口 (VegetableRepository / GardenRepository / CityRepository)
│   └── usecases/          # 业务用例 (GetRecommendedVegetables / AddVegetableToGarden / ...)
├── data/                  # 实现层
│   ├── datasources/       # SQLite / SharedPreferences / assets JSON 加载
│   ├── models/            # 带 fromJson / toJson / fromMap / toMap 的数据模型
│   └── repositories/      # 仓储实现 (VegetableRepositoryImpl / GardenRepositoryImpl / ...)
└── presentation/          # UI 层
    ├── pages/             # 13 个页面
    ├── providers/         # Riverpod Provider 拓扑 (core_providers / vegetable_providers / ...)
    └── widgets/           # 通用 widget (VegetableCard / GardenVegetableCard / ClimateZoneSelector)
```

## 三层依赖规则 (硬约束)

```
presentation ─→ domain ←─ data
   ↓             ↑           ↓
   └──── ❌ 禁止直接依赖 ────┘
```

**反向依赖 = 🔴 反模式**. 任何 page / widget 不能:
- `ref.watch(*LocalDatasourceProvider)` — 必须走 `*RepositoryProvider`
- `import '../../data/...'` 拿到 datasource / model

正确模式: page 用 `ref.watch(repositoryProvider)` → 仓库返回 `domain/entities` → page 用 entity.

`core_providers.dart` 里 datasource provider 是**实现细节**, 只允许 data 层内部使用. **T2 重构后这些 provider 应挪到 `data/providers/`.**

## 常用命令

```bash
# 装依赖
flutter pub get

# 跑全部测试 (本机执行可能超时, 别超过 60s)
flutter test

# 跑单个测试
flutter test test/data_seeder_test.dart

# 构建
flutter run -d <device_id>
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android AAB
flutter build ios --release
flutter build macos --release
flutter build windows --release
flutter build web --release

# 启用 json_serializable (T4 重构完成前先验证)
dart run build_runner build --delete-conflicting-outputs
```

## 数据模型概览

| 表 / 实体 | 关键字段 | 数据源 |
|---|---|---|
| `vegetables` | id / name / alias / category / sunlight / minTemp / maxTemp / soil / fertilizer / planting / nutrients / cautions / suitableClimates | `assets/data/vegetables.json` (60 种) |
| `cities` | name / province / climate_zone | **硬编码在 `lib/core/constants/app_constants.dart:16-442` (333 个城市)** — T5 计划挪到 `assets/data/cities.json` |
| `planting_calendar` | climate_zone / month / vegetable_ids | `assets/data/planting_calendar.json` |
| `my_garden` | id / vegetable_id / vegetable_name / sow_date / sunlight / status / created_at / updated_at | 用户运行时写入 |
| `garden_logs` | id / garden_id (FK) / date / note / photo_path | 用户运行时写入 |
| `reminders` | id / garden_id (FK) / type / time / is_done / created_at | 用户运行时写入 |

数据库 schema 在 `lib/core/constants/db_constants.dart`. 表创建 / 索引见 `DbSql.create*Table` / `DbSql.createIndexes`.

数据初始化流程: `main.dart` 调 `DataSeeder.seedIfNeeded()` → `database_helper.isDatabaseEmpty()` → 若空则批量写入 JSON 数据.

## 5 端适配约束

| 端 | SQLite | Notification | 备注 |
|---|---|---|---|
| Android | sqflite ✅ | flutter_local_notifications ✅ | 主目标 |
| iOS | sqflite ✅ | flutter_local_notifications ✅ | 需配 Info.plist 权限 |
| Web | **sqflite_common_ffi_web** ⚠️ | ❌ | IndexedDB 存储, 兼容性最差 |
| macOS | sqflite_common_ffi ✅ | ❌ | 启动时 `sqfliteFfiInit()` |
| Windows | sqflite_common_ffi ✅ | ❌ | 同 macOS |

`database_helper.dart:24-27` 自动检测桌面端切换 FFI. Web 端需额外配 `sqflite_common_ffi_web` (pubspec 已引).

**⚠️ 提醒功能目前只在 mobile 端能跑, 桌面/web 端调 `flutter_local_notifications` 会抛 PlatformException. UI 已做兜底, 别把提醒逻辑写死在 mobile-only 分支.**

## 已知架构问题 / TODO

### 🔴 重大
1. **反向依赖** — 3 个 page 跳过 Repository 直接 `ref.watch(*LocalDatasourceProvider)`:
   - `lib/presentation/pages/vegetable_library_page.dart:32`
   - `lib/presentation/pages/pest_disease_list_page.dart:160`
   - `lib/presentation/pages/pest_disease_detail_page.dart:360`
   - + `pest_disease_list_page.dart:116,230,368-371` 直接 `new PestDiseaseLocalDatasource()` (更严重, 连 Provider 都没用)
   - **T2 已修**: 改走 repository
2. **N+1 查询** — `lib/data/datasources/garden_local_datasource.dart:18-75` 3 个方法对每条记录额外查 2 次 DB.
3. **手写 JSON 序列化** — `pubspec.yaml` 引了 `json_serializable` 但 0 个 `.g.dart` 文件生成. 75 处 `fromJson/toJson` 全部手写.
4. **333 城市硬编码** — `lib/core/constants/app_constants.dart:16-442` 占 442 行 / 30KB. T5 计划挪到 `assets/data/cities.json`.

### 🟡 中等
5. **数据库迁移脚手架空架子** — `database_helper.dart:75-95` 的 `migrations` map 是空注释. **下次升 schema 必填, 否则老用户启动崩溃**.
6. **测试覆盖率 < 5%** — 只有 `test/widget_test.dart` (smoke) + `test/detail_screenshot_test.dart` (golden). 缺核心单元测试.
7. **错误处理两层** — Provider 层 `try/catch` + Repository 层 `throw UnimplementedError` 不一致.

### 🟢 小
8. `print()` / `debugPrint()` 散落 (data_seeder 4 处 + database_helper 1 处 + main.dart 2 处) — 已用 `core/utils/logger.dart` 替换.
9. 13 个页面平铺在 `presentation/pages/`, 大文件 962 行 (`vegetable_detail_page.dart`).
10. 5 个 model 都有 `fromEntity/toEntity`, boilerplate 重复.
11. pubspec 引了 `flutter_local_notifications` / `timezone` 但实际**没用**, 删掉可省 2-3MB.

## PR 提交规范

中文 commit message, 前缀:

- `feat:` 新功能
- `fix:` bug 修复
- `refactor:` 重构 (不改行为)
- `chore:` 杂项 (依赖 / 脚本)
- `docs:` 文档
- `test:` 测试
- `perf:` 性能

示例:
```
fix: 修复反向依赖,vegetable_library_page改走repository
chore: 清理data_seeder中残留的print
docs: 补CLAUDE.md项目AI上下文
```

## 关键文件位置速查

```
lib/main.dart                                    # 入口 + DataSeeder.seedIfNeeded()
lib/app.dart                                     # MaterialApp 配置
lib/core/constants/app_constants.dart            # 333 城市硬编码
lib/core/constants/db_constants.dart             # DbNames / DbTables / DbSql
lib/core/constants/enums.dart                    # ClimateZone / VegetableCategory / GardenStatus / BalconyDirection
lib/core/utils/logger.dart                       # 统一日志 (logger.i / logger.w / logger.e)
lib/data/datasources/database_helper.dart        # SQLite schema + 迁移
lib/data/datasources/vegetable_local_datasource.dart
lib/data/datasources/garden_local_datasource.dart
lib/data/datasources/pest_disease_local_datasource.dart
lib/data/datasources/city_local_datasource.dart
lib/data/datasources/settings_local_datasource.dart
lib/data/data_seeder.dart                        # 首次启动数据写入
lib/data/repositories/vegetable_repository_impl.dart
lib/data/repositories/garden_repository_impl.dart
lib/data/repositories/city_repository_impl.dart
lib/domain/repositories/vegetable_repository.dart
lib/domain/repositories/garden_repository.dart
lib/domain/repositories/city_repository.dart
lib/presentation/providers/core_providers.dart   # 全局 Provider 拓扑
lib/presentation/providers/vegetable_providers.dart
lib/presentation/providers/garden_providers.dart
lib/presentation/providers/city_providers.dart
lib/presentation/pages/                          # 13 个页面
```

## 修改代码前的检查清单

- [ ] 我是否破坏了 Clean Architecture 三层依赖? (presentation → domain ← data)
- [ ] 我加 / 改了 model 字段, `fromEntity` / `toEntity` / `fromMap` / `toMap` 全部同步了?
- [ ] 我加了新 page / provider, 是否在 `core_providers.dart` 注册了?
- [ ] 我改了 SQLite schema, 是否填了 `database_helper.dart` 的 `migrations` map?
- [ ] 我新增了 UI 字符串, 是否考虑了未来 i18n (虽然当前没做, 别把字符串散得太死)
- [ ] 我新增了 datasource, 是否在 `data/providers/` 下单独注册 Provider, 没污染 `core_providers.dart`?
- [ ] 我加了 print, 改成 `logger.i / logger.w / logger.e` (见 `lib/core/utils/logger.dart`)

## AI 改代码时的高频陷阱

1. **别用 `print` / `debugPrint`** — 用 `core/utils/logger.dart` 里的 `AppLogger`. `print` 在 release 包也会打.
2. **别在 widget 直接 `new Datasource()`** — 用 `ref.read(*LocalDatasourceProvider)` (data 层内部) 或 `ref.watch(*RepositoryProvider)` (presentation 层).
3. **别改 `app_constants.dart` 城市数组** — 442 行硬编码, 改完要重 build APK. T5 重构后再改.
4. **别在 page 直接 import `data/models/`** — 应该只看到 `domain/entities/`. 反向依赖会被 CI / 后续重构发现.
5. **schema 变更后必须填 migrations** — 别只改 `_onCreate`. 老用户从旧版本升级会启动崩溃.
6. **异步数据库操作的 await** — `ref.watch(...).getXxx()` 拿到的是 `Future`, 用 `AsyncValue.when()` / `FutureBuilder` 处理, 别忘了 loading / error 状态.
