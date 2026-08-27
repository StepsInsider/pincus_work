import '../../core/database/app_database.dart';

class SiteRepository {
  final AppDatabase _db = AppDatabase();

  List<Map<String, dynamic>> getAll() {
    return List<Map<String, dynamic>>.from(_db.sites);
  }

  Future<void> add({
    required String customerId,
    required String title,
    required String address,
    String status = 'Geplant',
    double value = 0,
  }) async {
    _db.sites.add({
      'id': 's_${DateTime.now().millisecondsSinceEpoch}',
      'customerId': customerId,
      'title': title,
      'address': address,
      'status': status,
      'value': value,
    });

    await _db.saveAll();
  }
}
