import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_providers.dart';

class MachineRepository {
  final AppDatabase _db;
  MachineRepository(this._db);

  Stream<List<Machine>> watchAllMachines() {
    return _db.select(_db.machines).watch();
  }

  Stream<List<Machine>> watchMachinesByStatus(String status) {
    return (_db.select(_db.machines)..where((m) => m.status.equals(status))).watch();
  }

  Future<int> addMachine({
    required String name,
    String? serialNumber,
    double operatingHours = 0.0,
    DateTime? nextInspectionDate,
    String? notes,
  }) {
    return _db.into(_db.machines).insert(MachinesCompanion.insert(
      name: name,
      serialNumber: Value(serialNumber),
      operatingHours: Value(operatingHours),
      nextInspectionDate: Value(nextInspectionDate),
      notes: Value(notes),
    ));
  }

  Future<void> updateOperatingHours(int machineId, double additionalHours) async {
    final machine = await (_db.select(_db.machines)..where((m) => m.id.equals(machineId))).getSingle();
    final newHours = machine.operatingHours + additionalHours;
    await (_db.update(_db.machines)..where((m) => m.id.equals(machineId))).write(
      MachinesCompanion(operatingHours: Value(newHours)),
    );
  }

  Future<void> updateMachine(int machineId, {
    String? name,
    String? serialNumber,
    double? operatingHours,
    DateTime? nextInspectionDate,
    String? status,
    String? notes,
  }) async {
    await (_db.update(_db.machines)..where((m) => m.id.equals(machineId))).write(
      MachinesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        serialNumber: serialNumber != null ? Value(serialNumber) : const Value.absent(),
        operatingHours: operatingHours != null ? Value(operatingHours) : const Value.absent(),
        nextInspectionDate: nextInspectionDate != null ? Value(nextInspectionDate) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteMachine(int machineId) async {
    await (_db.delete(_db.machines)..where((m) => m.id.equals(machineId))).go();
  }
}

final machineRepositoryProvider = Provider<MachineRepository>((ref) {
  return MachineRepository(ref.watch(databaseProvider));
});

final machinesStreamProvider = StreamProvider<List<Machine>>((ref) {
  return ref.watch(machineRepositoryProvider).watchAllMachines();
});

final machinesByStatusProvider = StreamProvider.family<List<Machine>, String>((ref, status) {
  return ref.watch(machineRepositoryProvider).watchMachinesByStatus(status);
});
