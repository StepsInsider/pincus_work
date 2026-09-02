import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_providers.dart';

class TaskRepository {
  final AppDatabase _db;
  TaskRepository(this._db);

  Stream<List<Task>> watchAllTasks() {
    return (_db.select(_db.tasks)..orderBy([(t) => OrderingTerm.desc(t.dueDate)])).watch();
  }

  Stream<List<Task>> watchTasksBySite(int siteId) {
    return (_db.select(_db.tasks)..where((t) => t.siteId.equals(siteId))..orderBy([(t) => OrderingTerm.desc(t.dueDate)])).watch();
  }

  Stream<List<Task>> watchTasksByStatus(String status) {
    return (_db.select(_db.tasks)..where((t) => t.status.equals(status))..orderBy([(t) => OrderingTerm.desc(t.dueDate)])).watch();
  }

  Future<int> createTask({
    int? siteId,
    required String title,
    String? description,
    required String category,
    required String priority,
    DateTime? dueDate,
  }) {
    return _db.into(_db.tasks).insert(TasksCompanion.insert(
      siteId: Value(siteId),
      title: title,
      description: Value(description),
      category: category,
      priority: priority,
      dueDate: Value(dueDate),
    ));
  }

  Future<void> updateTaskStatus(int taskId, String newStatus) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(status: Value(newStatus)),
    );
  }

  Future<void> updateTask(int taskId, {
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? dueDate,
    String? status,
  }) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(),
        priority: priority != null ? Value(priority) : const Value.absent(),
        dueDate: dueDate != null ? Value(dueDate) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteTask(int taskId) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(databaseProvider));
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks();
});

final tasksBySiteProvider = StreamProvider.family<List<Task>, int>((ref, siteId) {
  return ref.watch(taskRepositoryProvider).watchTasksBySite(siteId);
});

final tasksByStatusProvider = StreamProvider.family<List<Task>, String>((ref, status) {
  return ref.watch(taskRepositoryProvider).watchTasksByStatus(status);
});
