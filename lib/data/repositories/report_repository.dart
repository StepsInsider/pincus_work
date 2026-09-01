import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class ReportRepository {
  final AppDatabase _db;

  ReportRepository([AppDatabase? db]) : _db = db ?? AppDatabase();

  Future<List<Map<String, dynamic>>> getAll() async {
    final rows = await _db.select(_db.reports).get();

    return rows.map((report) {
      return {
        'id': report.id,
        'siteId': report.siteId,
        'title': report.title,
        'date': report.date,
        'content': report.content,
      };
    }).toList();
  }

  Future<void> add({
    required String siteId,
    required String title,
    required String date,
    required String content,
  }) async {
    await _db.into(_db.reports).insert(
          ReportsCompanion.insert(
            id: 'r_${DateTime.now().millisecondsSinceEpoch}',
            siteId: Value(int.tryParse(siteId)),
            title: title,
            date: date,
            content: content,
          ),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.reports)..where((r) => r.id.equals(id))).go();
  }
}
