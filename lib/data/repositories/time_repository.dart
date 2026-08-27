import '../../core/database/app_database.dart';

class TimeRepository {
  final AppDatabase _db = AppDatabase();

  List<Map<String, dynamic>> getAll() {
    return List<Map<String, dynamic>>.from(_db.timeEntries);
  }

  Future<void> add({
    required String employeeId,
    required String employeeName,
    required String siteId,
    required String siteTitle,
    required double hours,
    required String date,
    String note = '',
  }) async {
    _db.timeEntries.add({
      'id': 't_${DateTime.now().millisecondsSinceEpoch}',
      'employeeId': employeeId,
      'employeeName': employeeName,
      'siteId': siteId,
      'siteTitle': siteTitle,
      'hours': hours,
      'date': date,
      'note': note,
    });

    await _db.saveAll();
  }
}
