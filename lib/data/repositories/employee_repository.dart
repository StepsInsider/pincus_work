import '../../core/database/app_database.dart';

class EmployeeRepository {
  final AppDatabase _db = AppDatabase();

  List<Map<String, dynamic>> getAll() {
    return List<Map<String, dynamic>>.from(_db.employees);
  }

  Future<void> add({
    required String name,
    required String role,
    double targetHours = 40,
    String color = '0xFF2E7D32',
  }) async {
    _db.employees.add({
      'id': 'e_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'role': role,
      'targetHours': targetHours,
      'color': color,
    });

    await _db.saveAll();
  }
}
