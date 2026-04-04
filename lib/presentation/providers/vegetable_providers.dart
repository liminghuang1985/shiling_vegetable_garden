import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vegetable.dart';
import '../../domain/entities/planting_calendar.dart';
import '../../core/constants/enums.dart';
import 'core_providers.dart';

/// ========== 蔬菜列表 Provider ==========

/// 所有蔬菜列表
final allVegetablesProvider = FutureProvider<List<Vegetable>>((ref) async {
  final repository = ref.watch(vegetableRepositoryProvider);
  return repository.getAllVegetables();
});

/// 按分类筛选的蔬菜列表
final vegetablesByCategoryProvider = FutureProvider.family<List<Vegetable>, VegetableCategory?>((ref, category) async {
  final repository = ref.watch(vegetableRepositoryProvider);
  if (category == null) {
    return repository.getAllVegetables();
  }
  return repository.getVegetablesByCategory(category);
});

/// 按气候带筛选的蔬菜列表
final vegetablesByClimateProvider = FutureProvider.family<List<Vegetable>, ClimateZone>((ref, climate) async {
  final repository = ref.watch(vegetableRepositoryProvider);
  return repository.getVegetablesByClimate(climate);
});

/// ========== 搜索 Provider ==========

/// 搜索蔬菜结果
final searchVegetablesProvider = FutureProvider<List<Vegetable>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return [];
  }
  final useCase = ref.watch(searchVegetablesUseCaseProvider);
  return useCase(query);
});

/// ========== 蔬菜详情 Provider ==========

/// 蔬菜详情（按ID）
final vegetableDetailsProvider = FutureProvider.family<Vegetable?, String>((ref, id) async {
  final useCase = ref.watch(getVegetableDetailsUseCaseProvider);
  return useCase(id);
});

/// ========== 种植日历 Provider ==========

/// 种植日历
final plantingCalendarProvider = FutureProvider<PlantingCalendar>((ref) async {
  final useCase = ref.watch(getPlantingCalendarUseCaseProvider);
  return useCase();
});

/// 指定气候带的种植日历
final calendarForClimateProvider = FutureProvider.family<Map<int, List<String>>, ClimateZone>((ref, climate) async {
  final useCase = ref.watch(getPlantingCalendarUseCaseProvider);
  return useCase.getCalendarForClimate(climate);
});

/// ========== 推荐蔬菜 Provider ==========

/// 当前气候带当前月份的推荐蔬菜
final currentRecommendedVegetablesProvider = FutureProvider<List<Vegetable>>((ref) async {
  final climate = ref.watch(selectedClimateZoneProvider);
  final useCase = ref.watch(getRecommendedVegetablesUseCaseProvider);
  return useCase(climate);
});

/// 下个月推荐蔬菜
final nextMonthRecommendedVegetablesProvider = FutureProvider<List<Vegetable>>((ref) async {
  final climate = ref.watch(selectedClimateZoneProvider);
  final useCase = ref.watch(getRecommendedVegetablesUseCaseProvider);
  return useCase.getNextMonthRecommended(climate);
});

/// 指定气候带指定月份的推荐蔬菜
final recommendedVegetablesForMonthProvider = FutureProvider.family<List<Vegetable>, ({ClimateZone climate, int month})>((ref, params) async {
  final useCase = ref.watch(getRecommendedVegetablesUseCaseProvider);
  return useCase(params.climate, month: params.month);
});

/// ========== 筛选后的蔬菜列表 Provider ==========

/// 结合分类、气候带筛选的蔬菜列表
final filteredVegetablesProvider = FutureProvider<List<Vegetable>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final climate = ref.watch(selectedClimateZoneProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final repository = ref.watch(vegetableRepositoryProvider);

  List<Vegetable> vegetables;

  if (searchQuery.isNotEmpty) {
    vegetables = await repository.searchVegetables(searchQuery);
  } else if (category != null) {
    vegetables = await repository.getVegetablesByCategory(category);
  } else {
    vegetables = await repository.getAllVegetables();
  }

  // 进一步按气候带筛选
  if (searchQuery.isEmpty) {
    vegetables = vegetables.where((v) => v.suitableClimates.contains(climate)).toList();
  }

  return vegetables;
});
