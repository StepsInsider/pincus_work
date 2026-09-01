import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

class TimeRepository {
  final AppDatabase _db;

  TimeRepository([AppDatabase? db]) : _db = db ?? AppDatabase();

  Future<List<TimeEntry>> getAll() {
    return (_db.select(_db.timeEntries)
          ..orderBy([
            (t) => OrderingTerm.desc(t.startTime),
          ]))
        .get();
  }

  Future<int> add({
    required String employeeId,
    required String employeeName,
    required String siteId,
    required String siteTitle,
    required double hours,
    required String date,
    String note = '',
  }) {
    final start = DateTime.parse(date);

    final end = start.add(
      Duration(
        minutes: (hours * 60).round(),
      ),
    );

    return _db.into(_db.timeEntries).insert(
          TimeEntriesCompanion.insert(
            siteId: int.parse(siteId),
            employeeName: employeeName,
            date: start,
            startTime: start,
            endTime: Value(end),
            notes: Value(note),
          ),
        );
  }
}
