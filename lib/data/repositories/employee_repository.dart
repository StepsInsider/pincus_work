import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

class EmployeeRepository {
  final AppDatabase _db;

  EmployeeRepository([AppDatabase? db]) : _db = db ?? AppDatabase();

  Future<List<Map<String, dynamic>>> getAll() async {
    final rows = await _db.select(_db.employees).get();

    return rows.map((employee) {
      return {
        'id': employee.id,
        'name': employee.name,
        'role': employee.role,
        'targetHours': employee.targetHours,
        'color': employee.color,
      };
    }).toList();
  }

  Future<void> add({
    required String name,
    required String role,
    double targetHours = 40,
    String color = '0xFF2E7D32',
  }) async {
    await _db.into(_db.employees).insert(
          EmployeesCompanion.insert(
            id: 'e_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            role: role,
            targetHours: Value(targetHours),
            color: Value(color),
          ),
        );
  }

  Future<void> update({
    required String id,
    String? name,
    String? role,
    double? targetHours,
    String? color,
  }) async {
    await (_db.update(_db.employees)..where((e) => e.id.equals(id))).write(
      EmployeesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        role: role != null ? Value(role) : const Value.absent(),
        targetHours:
            targetHours != null ? Value(targetHours) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.employees)..where((e) => e.id.equals(id))).go();
  }
}
