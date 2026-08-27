import '../../core/database/app_database.dart';

class ReportRepository {
  final AppDatabase _db = AppDatabase();

  List<Map<String, dynamic>> getAll() {
    return List<Map<String, dynamic>>.from(_db.reports);
  }

  Future<void> add({
    required String siteId,
    required String title,
    required String date,
    required String content,
  }) async {
    _db.reports.add({
      'id': 'r_${DateTime.now().millisecondsSinceEpoch}',
      'siteId': siteId,
      'title': title,
      'date': date,
      'content': content,
    });

    await _db.saveAll();
  }
}
