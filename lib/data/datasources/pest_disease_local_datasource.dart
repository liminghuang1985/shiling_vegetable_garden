import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pest_disease_model.dart';

/// 病虫害本地数据源 - 从 assets/data/pest_diseases.json 加载
class PestDiseaseLocalDatasource {
  List<PestDiseaseModel>? _cache;

  /// 获取所有病虫害
  Future<List<PestDiseaseModel>> getAllPestDiseases() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('assets/data/pest_diseases.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _cache = jsonList.map((e) => PestDiseaseModel.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  /// 按类型获取（disease/pest）
  Future<List<PestDiseaseModel>> getByType(String type) async {
    final all = await getAllPestDiseases();
    return all.where((e) => e.type == type).toList();
  }

  /// 按蔬菜ID获取
  Future<List<PestDiseaseModel>> getByVegetableId(String vegId) async {
    final all = await getAllPestDiseases();
    return all.where((e) => e.targetVegetables.contains(vegId)).toList();
  }

  /// 按严重程度获取
  Future<List<PestDiseaseModel>> getBySeverity(String severity) async {
    final all = await getAllPestDiseases();
    return all.where((e) => e.severity == severity).toList();
  }

  /// 搜索病虫害
  Future<List<PestDiseaseModel>> search(String query) async {
    final all = await getAllPestDiseases();
    final q = query.toLowerCase();
    return all.where((e) =>
      e.name.toLowerCase().contains(q) ||
      (e.alias?.toLowerCase().contains(q) ?? false) ||
      e.symptoms.toLowerCase().contains(q)
    ).toList();
  }

  /// 清除缓存
  void clearCache() {
    _cache = null;
  }
}
