import '../../domain/entities/city.dart';
import '../../domain/repositories/city_repository.dart';
import '../../core/constants/enums.dart';
import '../datasources/city_local_datasource.dart';
import '../models/city_model.dart';

/// 城市仓储实现
class CityRepositoryImpl implements CityRepository {
  final CityLocalDatasource _localDatasource;

  CityRepositoryImpl(this._localDatasource);

  @override
  Future<List<City>> getAllCities() async {
    final models = await _localDatasource.getAllCities();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<City>> getCitiesByClimate(ClimateZone climate) async {
    final models = await _localDatasource.getCitiesByClimate(climate);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<City>> searchCities(String query) async {
    final models = await _localDatasource.searchCities(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<City?> getCityById(int id) async {
    final model = await _localDatasource.getCityById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveCities(List<City> cities) async {
    final models = cities.map((c) => CityModel.fromEntity(c)).toList();
    await _localDatasource.saveCities(models);
  }

  @override
  Future<void> syncFromCloud() async {
    // TODO: 实现云端同步逻辑
    // 预留接口，待接入云端API后实现
    throw UnimplementedError('云端同步功能待实现');
  }
}
