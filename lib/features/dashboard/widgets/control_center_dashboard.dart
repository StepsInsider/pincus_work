import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/data/task_repository.dart';
import '../../machines/data/machine_repository.dart';

class ControlCenterDashboard extends ConsumerWidget {
  const ControlCenterDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final machinesAsync = ref.watch(machinesStreamProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Offene Aufgaben Section
        const Text('Offene Aufgaben & Mängel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        tasksAsync.when(
          data: (tasks) {
            final openTasks = tasks.where((t) => t.status != 'erledigt').toList();
            return openTasks.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Keine offenen Aufgaben.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: openTasks.length,
                    itemBuilder: (context, index) {
                      final task = openTasks[index];
                      final priorityColor = _getPriorityColor(task.priority);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: priorityColor,
                            ),
                          ),
                          title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('${task.category} • Priorität: ${task.priority}'),
                          trailing: Chip(
                            label: Text(task.status),
                            backgroundColor: _getStatusColor(task.status),
                          ),
                        ),
                      );
                    },
                  );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Fehler beim Laden: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
        const Divider(height: 32),

        // Maschinen Section
        const Text('Maschinen- & Fuhrparkstatus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        machinesAsync.when(
          data: (machines) => machines.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Keine Maschinen hinterlegt.', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: machines.length,
                  itemBuilder: (context, index) {
                    final machine = machines[index];
                    final statusColor = _getMachineStatusColor(machine.status);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: Icon(Icons.build_circle, color: statusColor),
                        title: Text(machine.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Betriebsstunden: ${machine.operatingHours.toStringAsFixed(1)}h'),
                            if (machine.nextInspectionDate != null)
                              Text('Nächste Prüfung: ${_formatDate(machine.nextInspectionDate!)}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(machine.status),
                          backgroundColor: statusColor.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Fehler beim Laden: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'dringend':
        return Colors.red;
      case 'hoch':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'niedrig':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'offen':
        return Colors.red.withOpacity(0.2);
      case 'in_arbeit':
        return Colors.orange.withOpacity(0.2);
      case 'erledigt':
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getMachineStatusColor(String status) {
    switch (status) {
      case 'bereit':
        return Colors.green;
      case 'im_einsatz':
        return Colors.blue;
      case 'wartung':
        return Colors.orange;
      case 'defekt':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
