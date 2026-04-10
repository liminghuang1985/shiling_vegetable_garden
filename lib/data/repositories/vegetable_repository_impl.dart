import '../../domain/entities/vegetable.dart';
import '../../domain/entities/planting_calendar.dart';
import '../../domain/repositories/vegetable_repository.dart';
import '../../core/constants/enums.dart';
import '../datasources/vegetable_local_datasource.dart';
import '../models/vegetable_model.dart';

/// 蔬菜仓储实现
class VegetableRepositoryImpl implements VegetableRepository {
  final VegetableLocalDatasource _localDatasource;

  VegetableRepositoryImpl(this._localDatasource);

  @override
  Future<List<Vegetable>> getAllVegetables() async {
    final models = await _localDatasource.getAllVegetables();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Vegetable>> getVegetablesByCategory(VegetableCategory category) async {
    final models = await _localDatasource.getVegetablesByCategory(category);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Vegetable>> getVegetablesByClimate(ClimateZone climate) async {
    final models = await _localDatasource.getVegetablesByClimate(climate);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Vegetable?> getVegetableById(String id) async {
    final model = await _localDatasource.getVegetableById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Vegetable>> searchVegetables(String query) async {
    final models = await _localDatasource.searchVegetables(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveVegetables(List<Vegetable> vegetables) async {
    final models = vegetables.map((v) => VegetableModel.fromEntity(v)).toList();
    await _localDatasource.saveVegetables(models);
  }

  @override
  Future<PlantingCalendar> getPlantingCalendar() async {
    return await _localDatasource.getPlantingCalendar();
  }

  @override
  Future<List<Vegetable>> getRecommendedVegetables(ClimateZone climate, int month) async {
    final vegIds = await _localDatasource.getVegetableIdsForClimateAndMonth(climate, month);
    if (vegIds.isEmpty) {
      return [];
    }
    final models = await _localDatasource.getVegetablesByIds(vegIds);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> syncFromCloud() async {
    // TODO: 实现云端同步逻辑
    // 预留接口，待接入云端API后实现
    throw UnimplementedError('云端同步功能待实现');
  }
}
