import '../../core/database/app_database.dart';

class OrderRepository {
  final AppDatabase _db = AppDatabase();

  List<Map<String, dynamic>> getAll() {
    return List<Map<String, dynamic>>.from(_db.orders);
  }

  Future<void> add({
    required String siteId,
    required String customerId,
    required String title,
    String status = 'Neu',
    required String date,
    double price = 0,
  }) async {
    _db.orders.add({
      'id': 'o_${DateTime.now().millisecondsSinceEpoch}',
      'siteId': siteId,
      'customerId': customerId,
      'title': title,
      'status': status,
      'date': date,
      'price': price,
    });

    await _db.saveAll();
  }
}
