import '../../core/database/app_database.dart';

class CustomerRepository {
  final AppDatabase _db = AppDatabase();

  List<Map<String, dynamic>> getAll() {
    return List<Map<String, dynamic>>.from(_db.customers);
  }

  Future<void> add({
    required String name,
    String contact = '',
    String phone = '',
    String address = '',
  }) async {
    _db.customers.add({
      'id': 'c_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'contact': contact,
      'phone': phone,
      'address': address,
    });

    await _db.saveAll();
  }
}
