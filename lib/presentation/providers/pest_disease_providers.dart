import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/pest_disease_repository.dart';
import '../../data/datasources/pest_disease_local_datasource.dart';
import '../../data/repositories/pest_disease_repository_impl.dart';

/// 病虫害本地数据源 Provider
/// T2 重构: 从 core_providers.dart 分离出 data layer provider
final pestDiseaseLocalDatasourceProvider = Provider<PestDiseaseLocalDatasource>((ref) {
  return PestDiseaseLocalDatasource();
});

/// 病虫害仓储 Provider
/// T2 重构: page 通过这个 provider 获取数据, 不再直接 new PestDiseaseLocalDatasource
final pestDiseaseRepositoryProvider = Provider<PestDiseaseRepository>((ref) {
  final datasource = ref.watch(pestDiseaseLocalDatasourceProvider);
  return PestDiseaseRepositoryImpl(datasource);
});
