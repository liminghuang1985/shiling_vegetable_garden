import 'package:flutter_test/flutter_test.dart';
import 'package:shiling_vegetable_garden/core/constants/enums.dart';
import 'package:shiling_vegetable_garden/data/models/garden_model.dart';

void main() {
  test('garden_model.g.dart roundtrip preserves garden data', () {
    final json = <String, dynamic>{
      'id': 'garden-1',
      'vegetable_id': 'fq',
      'vegetable_name': '番茄',
      'sow_date': '2026-03-01T08:00:00.000',
      'sunlight': 'south',
      'status': 'growing',
      'created_at': '2026-03-01T08:00:00.000',
      'updated_at': '2026-03-02T09:00:00.000',
      'logs': [
        {
          'id': 1,
          'garden_id': 'garden-1',
          'date': '2026-03-02T09:00:00.000',
          'note': '首次浇水',
          'photo_path': '/tmp/garden.jpg',
        },
      ],
      'reminders': [
        {
          'id': 'reminder-1',
          'garden_id': 'garden-1',
          'type': 'water',
          'time': '2026-03-03T08:00:00.000',
          'is_done': false,
          'created_at': '2026-03-01T08:00:00.000',
        },
      ],
    };

    final model = GardenVegetableModel.fromJson(json);
    final roundtrip = model.toJson();

    expect(model.sunlight, BalconyDirection.south);
    expect(model.status, GardenStatus.growing);
    expect(model.logs.single.note, '首次浇水');
    expect(model.reminders.single.type, ReminderType.water);
    expect(roundtrip, json);
  });
}
