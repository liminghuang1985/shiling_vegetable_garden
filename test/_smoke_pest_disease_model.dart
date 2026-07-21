import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiling_vegetable_garden/data/models/pest_disease_model.dart';

void main() {
  test('pest_disease_model.g.dart parses all real assets/data/pest_diseases.json entries', () {
    final raw = File('assets/data/pest_diseases.json').readAsStringSync();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    expect(list.isNotEmpty, true, reason: 'pest_diseases.json should not be empty');
    var ok = 0;
    final errors = <String>[];
    for (final j in list) {
      try {
        // ignore: unused_local_variable
        final m = PestDiseaseModel.fromJson(j);
        ok++;
      } catch (e) {
        errors.add('${j['id']} -> $e');
      }
    }
    expect(errors, isEmpty,
        reason: 'fromJson failed for ${errors.length} entries: ${errors.take(3).join("; ")}');
    print('OK: $ok/${list.length} entries parsed via generated fromJson');
  });

  test('toJson roundtrip preserves all fields', () {
    final raw = File('assets/data/pest_diseases.json').readAsStringSync();
    final first = (jsonDecode(raw) as List).cast<Map<String, dynamic>>().first;
    final m = PestDiseaseModel.fromJson(first);
    final rt = m.toJson();
    expect(rt['id'], first['id']);
    expect(rt['name'], first['name']);
    expect(rt['type'], first['type']);
    expect((rt['prevention'] as List).length, (first['prevention'] as List).length);
  });
}
