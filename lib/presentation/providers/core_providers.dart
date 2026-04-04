import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/city_repository_impl.dart';
import '../../data/repositories/vegetable_repository_impl.dart';
import '../../data/repositories/garden_repository_impl.dart';
import '../../domain/repositories/city_repository.dart';
import '../../domain/repositories/vegetable_repository.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../domain/usecases/vegetable_usecases.dart';
import '../../domain/usecases/garden_usecases.dart';
import '../../core/constants/enums.dart';

/// 城市仓储
final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepositoryImpl();
});

/// 蔬菜仓储
final vegetableRepositoryProvider = Provider<VegetableRepository>((ref) {
  return VegetableRepositoryImpl();
});

/// 用户菜园仓储
final gardenRepositoryProvider = Provider<GardenRepository>((ref) {
  return GardenRepositoryImpl();
});

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

/// 当前选择的气候带
final selectedClimateZoneProvider = StateProvider<ClimateZone>((ref) {
  return ClimateZone.warmTemperate;
});

/// 当前选择的分类
final selectedCategoryProvider = StateProvider<VegetableCategory?>((ref) {
  return null;
});

/// 搜索关键词
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// 阳台朝向
final balconyDirectionProvider = StateProvider<BalconyDirection>((ref) {
  return BalconyDirection.south;
});
