import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_providers.dart';

class TimeRepository {
  final AppDatabase _db;
  TimeRepository(this._db);

  /// Alle Zeiteinträge anschauen
  Stream<List<TimeEntry>> watchAllTimeEntries() {
    return (_db.select(_db.timeEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .watch();
  }

  /// Zeiteinträge für eine bestimmte Baustelle anschauen
  Stream<List<TimeEntry>> watchTimeEntriesBySite(int siteId) {
    return (_db.select(_db.timeEntries)
          ..where((t) => t.siteId.equals(siteId))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .watch();
  }

  /// Zeiteinträge für einen bestimmten Mitarbeiter anschauen
  Stream<List<TimeEntry>> watchTimeEntriesByEmployee(String employeeName) {
    return (_db.select(_db.timeEntries)
          ..where((t) => t.employeeName.equals(employeeName))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .watch();
  }

  /// Zeiteinträge für einen Datumsbereich anschauen
  Stream<List<TimeEntry>> watchTimeEntriesByDateRange(
      DateTime startDate, DateTime endDate) {
    return (_db.select(_db.timeEntries)
          ..where((t) =>
              t.startTime.isBiggerOrEqualValue(startDate) &
              t.startTime.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .watch();
  }

  /// Neue Zeiteintrag erstellen
  Future<int> createTimeEntry({
    required int siteId,
    required String employeeName,
    required DateTime date,
    required DateTime startTime,
    DateTime? endTime,
    double breakMinutes = 0.0,
    String? notes,
  }) {
    return _db.into(_db.timeEntries).insert(TimeEntriesCompanion.insert(
      siteId: siteId,
      employeeName: employeeName,
      date: date,
      startTime: startTime,
      endTime: Value(endTime),
      breakMinutes: Value(breakMinutes),
      notes: Value(notes),
    ));
  }

  /// Zeiteintrag beenden (Endzeit setzen)
  Future<void> stopTimeEntry(int timeEntryId, DateTime endTime) async {
    await (_db.update(_db.timeEntries)..where((t) => t.id.equals(timeEntryId)))
        .write(TimeEntriesCompanion(endTime: Value(endTime)));
  }

  /// Zeiteintrag aktualisieren
  Future<void> updateTimeEntry(
    int timeEntryId, {
    DateTime? startTime,
    DateTime? endTime,
    double? breakMinutes,
    String? notes,
  }) async {
    await (_db.update(_db.timeEntries)..where((t) => t.id.equals(timeEntryId)))
        .write(TimeEntriesCompanion(
      startTime: startTime != null ? Value(startTime) : const Value.absent(),
      endTime: endTime != null ? Value(endTime) : const Value.absent(),
      breakMinutes:
          breakMinutes != null ? Value(breakMinutes) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
    ));
  }

  /// Zeiteintrag löschen
  Future<void> deleteTimeEntry(int timeEntryId) async {
    await (_db.delete(_db.timeEntries)..where((t) => t.id.equals(timeEntryId)))
        .go();
  }

  /// Berechne Arbeitszeit für einen Eintrag (in Stunden)
  double calculateWorkingHours(TimeEntry entry) {
    if (entry.endTime == null) return 0.0;
    final duration = entry.endTime!.difference(entry.startTime);
    final breakDuration = Duration(minutes: entry.breakMinutes.toInt());
    final netDuration = duration - breakDuration;
    return netDuration.inMinutes / 60.0;
  }
}

// Riverpod Provider Definitionen
final timeRepositoryProvider = Provider<TimeRepository>((ref) {
  return TimeRepository(ref.watch(databaseProvider));
});

final timeEntriesStreamProvider = StreamProvider<List<TimeEntry>>((ref) {
  return ref.watch(timeRepositoryProvider).watchAllTimeEntries();
});

final timeEntriesBySiteProvider =
    StreamProvider.family<List<TimeEntry>, int>((ref, siteId) {
  return ref.watch(timeRepositoryProvider).watchTimeEntriesBySite(siteId);
});

final timeEntriesByEmployeeProvider =
    StreamProvider.family<List<TimeEntry>, String>((ref, employeeName) {
  return ref.watch(timeRepositoryProvider).watchTimeEntriesByEmployee(employeeName);
});

final timeEntriesByDateRangeProvider = StreamProvider.family<List<TimeEntry>,
    ({DateTime start, DateTime end})>((ref, dateRange) {
  return ref.watch(timeRepositoryProvider).watchTimeEntriesByDateRange(
      dateRange.start, dateRange.end);
});
