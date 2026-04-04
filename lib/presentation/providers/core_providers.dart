import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/datasources/city_local_datasource.dart';
import '../../data/datasources/vegetable_local_datasource.dart';
import '../../data/datasources/garden_local_datasource.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/city_repository_impl.dart';
import '../../data/repositories/vegetable_repository_impl.dart';
import '../../data/repositories/garden_repository_impl.dart';
import '../../domain/repositories/city_repository.dart';
import '../../domain/repositories/vegetable_repository.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../domain/usecases/vegetable_usecases.dart';
import '../../domain/usecases/garden_usecases.dart';
import '../../core/constants/enums.dart';

/// ========== 数据库相关 Provider ==========

/// 数据库单例
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// 设置本地数据源（SharedPreferences）
final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>((ref) {
  return SettingsLocalDatasource();
});

/// ========== 数据源 Provider ==========

/// 城市本地数据源
final cityLocalDatasourceProvider = Provider<CityLocalDatasource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CityLocalDatasource(dbHelper);
});

/// 蔬菜本地数据源
final vegetableLocalDatasourceProvider = Provider<VegetableLocalDatasource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return VegetableLocalDatasource(dbHelper);
});

/// 用户菜园本地数据源
final gardenLocalDatasourceProvider = Provider<GardenLocalDatasource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return GardenLocalDatasource(dbHelper);
});

/// ========== 仓储 Provider ==========

/// 城市仓储
final cityRepositoryProvider = Provider<CityRepository>((ref) {
  final datasource = ref.watch(cityLocalDatasourceProvider);
  return CityRepositoryImpl(datasource);
});

/// 蔬菜仓储
final vegetableRepositoryProvider = Provider<VegetableRepository>((ref) {
  final datasource = ref.watch(vegetableLocalDatasourceProvider);
  return VegetableRepositoryImpl(datasource);
});

/// 用户菜园仓储
final gardenRepositoryProvider = Provider<GardenRepository>((ref) {
  final datasource = ref.watch(gardenLocalDatasourceProvider);
  return GardenRepositoryImpl(datasource);
});

/// ========== 用例 Provider ==========

/// 获取推荐蔬菜用例
final getRecommendedVegetablesUseCaseProvider = Provider<GetRecommendedVegetablesUseCase>((ref) {
  final repository = ref.watch(vegetableRepositoryProvider);
  return GetRecommendedVegetablesUseCase(repository);
});

/// 获取蔬菜详情用例
final getVegetableDetailsUseCaseProvider = Provider<GetVegetableDetailsUseCase>((ref) {
  final repository = ref.watch(vegetableRepositoryProvider);
  return GetVegetableDetailsUseCase(repository);
});

/// 搜索蔬菜用例
final searchVegetablesUseCaseProvider = Provider<SearchVegetablesUseCase>((ref) {
  final repository = ref.watch(vegetableRepositoryProvider);
  return SearchVegetablesUseCase(repository);
});

/// 获取种植日历用例
final getPlantingCalendarUseCaseProvider = Provider<GetPlantingCalendarUseCase>((ref) {
  final repository = ref.watch(vegetableRepositoryProvider);
  return GetPlantingCalendarUseCase(repository);
});

/// 添加蔬菜到菜园用例
final addVegetableToGardenUseCaseProvider = Provider<AddVegetableToGardenUseCase>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return AddVegetableToGardenUseCase(repository);
});

/// 获取我的菜园用例
final getMyGardenUseCaseProvider = Provider<GetMyGardenUseCase>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return GetMyGardenUseCase(repository);
});

/// 更新菜园状态用例
final updateGardenStatusUseCaseProvider = Provider<UpdateGardenStatusUseCase>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return UpdateGardenStatusUseCase(repository);
});

/// 删除菜园蔬菜用例
final deleteGardenVegetableUseCaseProvider = Provider<DeleteGardenVegetableUseCase>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return DeleteGardenVegetableUseCase(repository);
});

/// 生长日志管理用例
final manageGardenLogsUseCaseProvider = Provider<ManageGardenLogsUseCase>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return ManageGardenLogsUseCase(repository);
});

/// 提醒管理用例
final manageRemindersUseCaseProvider = Provider<ManageRemindersUseCase>((ref) {
  final repository = ref.watch(gardenRepositoryProvider);
  return ManageRemindersUseCase(repository);
});

/// ========== 状态 Provider ==========

/// 当前选择的气候带
final selectedClimateZoneProvider = StateProvider<ClimateZone>((ref) {
  return ClimateZone.warmTemperate; // 默认暖温带
});

/// 当前选择的分类
final selectedCategoryProvider = StateProvider<VegetableCategory?>((ref) {
  return null; // null 表示全部分类
});

/// 搜索关键词
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// 阳台朝向
final balconyDirectionProvider = StateProvider<BalconyDirection>((ref) {
  return BalconyDirection.south; // 默认南向阳台
});
