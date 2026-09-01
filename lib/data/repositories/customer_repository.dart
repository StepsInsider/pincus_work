import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class CustomerRepository {
  final AppDatabase _db;

  CustomerRepository([AppDatabase? db]) : _db = db ?? AppDatabase();

  Future<List<Map<String, dynamic>>> getAll() async {
    final rows = await _db.select(_db.customers).get();

    return rows.map((customer) {
      return {
        'id': customer.id,
        'name': customer.name,
        'contact': customer.contact,
        'phone': customer.phone,
        'address': customer.address,
      };
    }).toList();
  }

  Future<void> add({
    required String name,
    String contact = '',
    String phone = '',
    String address = '',
  }) async {
    await _db.into(_db.customers).insert(
          CustomersCompanion.insert(
            id: 'c_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            contact: Value(contact),
            phone: Value(phone),
            address: Value(address),
          ),
        );
  }

  Future<void> update({
    required String id,
    String? name,
    String? contact,
    String? phone,
    String? address,
  }) async {
    await (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
      CustomersCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        contact: contact != null ? Value(contact) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        address: address != null ? Value(address) : const Value.absent(),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.customers)..where((c) => c.id.equals(id))).go();
  }
}
