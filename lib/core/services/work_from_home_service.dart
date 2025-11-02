import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../models/work_from_home_entry.dart';

class WorkFromHomeService {
  static const double deductionRateAudPerHour = 0.67;

  final DatabaseHelper dbHelper;
  final Uuid _uuid = const Uuid();

  WorkFromHomeService({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<WorkFromHomeEntry>> getEntries() async {
    return dbHelper.getWorkFromHomeEntries();
  }

  Future<void> saveWeekSchedule(Map<DateTime, double> hoursPerDay) async {
    final Map<DateTime, double> normalized = {};
    for (final entry in hoursPerDay.entries) {
      final day = DateTime(entry.key.year, entry.key.month, entry.key.day);
      final hours = entry.value;
      if (hours <= 0) {
        await dbHelper.deleteWorkFromHomeEntryByDate(day);
        continue;
      }
      normalized[day] = hours;
    }

    if (normalized.isEmpty) {
      return;
    }

    final entries = normalized.entries
        .map(
          (entry) => WorkFromHomeEntry(
            id: _uuid.v4(),
            workingDate: entry.key,
            hours: entry.value,
          ),
        )
        .toList();
    await dbHelper.upsertWorkFromHomeEntries(entries);
  }

  Future<void> deleteEntry(String id) async {
    await dbHelper.deleteWorkFromHomeEntry(id);
  }

  double calculatePotentialSavings(double totalHours) {
    if (totalHours <= 0) {
      return 0;
    }
    return totalHours * deductionRateAudPerHour;
  }

  double totalLoggedHours(List<WorkFromHomeEntry> entries) {
    return entries.fold(
        0, (previousValue, element) => previousValue + element.hours);
  }
}
