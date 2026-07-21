import '../../data/datasources/pest_disease_local_datasource.dart';
import '../../data/models/pest_disease_model.dart';

/// 病虫害仓储接口
/// T2 重构新增: 之前 page 直接 new PestDiseaseLocalDatasource, 违反 Clean Architecture
///
/// ⚠️ 设计妥协: 当前返回 PestDiseaseModel (data model) 而非 domain entity.
/// 原因: 项目目前没有 PestDiseaseEntity, model 也无复杂逻辑, 复用可减少 200+ 行 boilerplate.
/// 未来若引入 PestDiseaseEntity, 改为返回 entity 即可. Repository 实现层做 model→entity 转换.
abstract class PestDiseaseRepository {
  Future<List<PestDiseaseModel>> getAllPestDiseases();
  Future<List<PestDiseaseModel>> getByType(String type);
  Future<List<PestDiseaseModel>> getByVegetableId(String vegId);
  Future<List<PestDiseaseModel>> getBySeverity(String severity);
  Future<List<PestDiseaseModel>> search(String query);
}
