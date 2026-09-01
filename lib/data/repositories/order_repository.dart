import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class OrderRepository {
  final AppDatabase _db;

  OrderRepository([AppDatabase? db]) : _db = db ?? AppDatabase();

  Future<List<Map<String, dynamic>>> getAll() async {
    final rows = await _db.select(_db.orders).get();

    return rows.map((order) {
      return {
        'id': order.id,
        'siteId': order.siteId,
        'customerId': order.customerId,
        'title': order.title,
        'status': order.status,
        'date': order.date,
        'price': order.price,
      };
    }).toList();
  }

  Future<void> add({
    required String siteId,
    required String customerId,
    required String title,
    String status = 'Neu',
    required String date,
    double price = 0,
  }) async {
    final parsedSiteId = int.tryParse(siteId);

    await _db.into(_db.orders).insert(
          OrdersCompanion.insert(
            id: 'o_${DateTime.now().millisecondsSinceEpoch}',
            siteId: Value(parsedSiteId),
            customerId: Value(customerId),
            title: title,
            status: Value(status),
            date: date,
            price: Value(price),
          ),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.orders)..where((o) => o.id.equals(id))).go();
  }
}
