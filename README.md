# 时令菜园 (Shiling Vegetable Garden)

> 基于中国气候带的时令蔬菜种植指南 App. Flutter 5 端 (Android / iOS / Web / macOS / Windows).

## 项目定位

为阳台 / 小菜园用户提供**按气候带过滤的蔬菜推荐 + 种植日历 + 我的菜园管理 + 病虫害识别**的离线 App.

作者: 黄黎明 (`liminghuang1985`). 个人项目, 已发 APK v2 (77.6MB).

## 一句话

按气候带过滤蔬菜推荐 + 种植日历 + 菜园管理 + 病虫害识别.

## 跑起来

```bash
git clone https://github.com/liminghuang1985/shiling_vegetable_garden.git
cd shiling_vegetable_garden
flutter pub get
flutter run
```

## 5 端构建

```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android AAB
flutter build ios --release
flutter build macos --release
flutter build windows --release
flutter build web --release
```

## 数据源

- 60 种蔬菜数据来自 `assets/data/vegetables.json`
- 333 城市硬编码在 `lib/core/constants/app_constants.dart` (T5 重构后会挪到 JSON)
- 病虫害 100+ 条来自 `assets/data/pest_diseases.json`
- 种植日历来自 `assets/data/planting_calendar.json`

## 项目架构

Clean Architecture (`domain` / `data` / `presentation`). 详见 [CLAUDE.md](./CLAUDE.md).

依赖规则 (硬约束):

```
presentation ─→ domain ←─ data
```

**反向依赖 = 🔴 反模式**. 任何 page / widget 不能直接 `ref.watch(*LocalDatasourceProvider)`, 必须走 `*RepositoryProvider`.

## 关键命令

```bash
flutter test                                             # 跑全部测试
flutter test test/garden_local_datasource_test.dart      # 跑 N+1 测试
flutter test test/database_migration_test.dart           # 跑迁移测试
dart run build_runner build --delete-conflicting-outputs  # json_serializable 生成
flutter analyze                                          # 静态分析
```

## 截图占位

<!-- TODO: 加 4 端截图 -->