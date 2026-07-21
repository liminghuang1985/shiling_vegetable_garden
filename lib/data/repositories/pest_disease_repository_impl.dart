import '../../domain/repositories/pest_disease_repository.dart';
import '../datasources/pest_disease_local_datasource.dart';
import '../models/pest_disease_model.dart';

/// PestDiseaseRepository 实现
/// 位于 data 层, 实现 domain 接口
class PestDiseaseRepositoryImpl implements PestDiseaseRepository {
  final PestDiseaseLocalDatasource _datasource;

  PestDiseaseRepositoryImpl(this._datasource);

  @override
  Future<List<PestDiseaseModel>> getAllPestDiseases() =>
      _datasource.getAllPestDiseases();

  @override
  Future<List<PestDiseaseModel>> getByType(String type) =>
      _datasource.getByType(type);

  @override
  Future<List<PestDiseaseModel>> getByVegetableId(String vegId) =>
      _datasource.getByVegetableId(vegId);

  @override
  Future<List<PestDiseaseModel>> getBySeverity(String severity) =>
      _datasource.getBySeverity(severity);

  @override
  Future<List<PestDiseaseModel>> search(String query) =>
      _datasource.search(query);
}
