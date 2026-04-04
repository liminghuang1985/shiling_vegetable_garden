import '../entities/vegetable.dart';
import '../entities/planting_calendar.dart';
import '../repositories/vegetable_repository.dart';
import '../../core/constants/enums.dart';

/// 获取推荐蔬菜用例
class GetRecommendedVegetablesUseCase {
  final VegetableRepository _repository;

  GetRecommendedVegetablesUseCase(this._repository);

  /// 获取当前季节推荐的蔬菜
  Future<List<Vegetable>> call(ClimateZone climate, {int? month}) async {
    final targetMonth = month ?? DateTime.now().month;
    return _repository.getRecommendedVegetables(climate, targetMonth);
  }

  /// 获取下个月推荐的蔬菜
  Future<List<Vegetable>> getNextMonthRecommended(ClimateZone climate) async {
    final nextMonth = ((DateTime.now().month) % 12) + 1;
    return _repository.getRecommendedVegetables(climate, nextMonth);
  }
}

/// 获取蔬菜详情用例
class GetVegetableDetailsUseCase {
  final VegetableRepository _repository;

  GetVegetableDetailsUseCase(this._repository);

  Future<Vegetable?> call(String vegetableId) {
    return _repository.getVegetableById(vegetableId);
  }
}

/// 搜索蔬菜用例
class SearchVegetablesUseCase {
  final VegetableRepository _repository;

  SearchVegetablesUseCase(this._repository);

  Future<List<Vegetable>> call(String query) {
    return _repository.searchVegetables(query);
  }
}

/// 获取种植日历用例
class GetPlantingCalendarUseCase {
  final VegetableRepository _repository;

  GetPlantingCalendarUseCase(this._repository);

  Future<PlantingCalendar> call() {
    return _repository.getPlantingCalendar();
  }

  /// 获取指定气候带的种植日历
  Future<Map<int, List<String>>> getCalendarForClimate(ClimateZone climate) async {
    final calendar = await _repository.getPlantingCalendar();
    return calendar.data[climate] ?? {};
  }
}
