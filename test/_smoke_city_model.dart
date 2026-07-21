import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiling_vegetable_garden/data/models/city_model.dart';

void main() {
  test('city_model.g.dart roundtrips all real cities.json entries', () {
    final raw = File('assets/data/cities.json').readAsStringSync();
    final cities = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    expect(cities, hasLength(364));
    for (final json in cities) {
      final model = CityModel.fromJson(json);
      expect(model.toJson(), <String, dynamic>{'id': null, ...json});
    }
  });
}
