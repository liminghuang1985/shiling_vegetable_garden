import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/city.dart';
import '../../core/constants/enums.dart';
import 'core_providers.dart';

/// ========== 城市列表 Provider ==========

/// 所有城市
final allCitiesProvider = FutureProvider<List<City>>((ref) async {
  final repository = ref.watch(cityRepositoryProvider);
  return repository.getAllCities();
});

/// 按气候带筛选的城市
final citiesByClimateProvider = FutureProvider.family<List<City>, ClimateZone>((ref, climate) async {
  final repository = ref.watch(cityRepositoryProvider);
  return repository.getCitiesByClimate(climate);
});

/// 城市搜索结果
final citySearchProvider = FutureProvider.family<List<City>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final repository = ref.watch(cityRepositoryProvider);
  return repository.searchCities(query);
});

/// ========== 当前选择 Provider ==========

/// 当前选择的城市
final selectedCityProvider = StateProvider<City?>((ref) {
  return null;
});

/// 当前选择的气候带（简化版，用户可以直接选择气候带而不选城市）
final directClimateZoneProvider = StateProvider<ClimateZone>((ref) {
  return ClimateZone.warmTemperate;
});
