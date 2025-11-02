import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/work_from_home_entry.dart';

void main() {
  test('WorkFromHomeEntry serializes correctly', () {
    final entry = WorkFromHomeEntry(
      id: 'abc',
      workingDate: DateTime(2024, 5, 20),
      hours: 6.5,
    );

    final map = entry.toMap();
    expect(map['id'], 'abc');
    expect(map['workingDate'], DateTime(2024, 5, 20).toIso8601String());
    expect(map['hours'], 6.5);

    final fromMap = WorkFromHomeEntry.fromMap(map);
    expect(fromMap.id, entry.id);
    expect(fromMap.workingDate, entry.workingDate);
    expect(fromMap.hours, entry.hours);
  });

  test('WorkFromHomeEntry copyWith updates fields', () {
    final entry = WorkFromHomeEntry(
      id: 'abc',
      workingDate: DateTime(2024, 1, 1),
      hours: 4,
    );

    final updated = entry.copyWith(hours: 7.5);
    expect(updated.hours, 7.5);
    expect(updated.id, entry.id);
    expect(updated.workingDate, entry.workingDate);
  });
}
