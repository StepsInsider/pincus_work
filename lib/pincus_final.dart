import 'package:flutter/material.dart';

const green = Color(0xFF2E7D32);
const darkGreen = Color(0xFF1B5E20);
const paleGreen = Color(0xFFE8F5E9);
const bg = Color(0xFFF5F8F4);

enum Module { dashboard, sites, customers, orders, employees, time, calendar, reports, materials, machines, tasks }

String moduleLabel(Module module) {
  switch (module) {
    case Module.dashboard: return 'Dashboard';
    case Module.sites: return 'Baustellen';
    case Module.customers: return 'Kunden';
    case Module.orders: return 'Aufträge';
    case Module.employees: return 'Mitarbeiter';
    case Module.time: return 'Zeiterfassung';
    case Module.calendar: return 'Kalender';
    case Module.reports: return 'Berichte';
    case Module.materials: return 'Material';
    case Module.machines: return 'Maschinen';
    case Module.tasks: return 'Aufgaben';
  }
}

IconData moduleIcon(Module module) {
  switch (module) {
    case Module.dashboard: return Icons.dashboard_outlined;
    case Module.sites: return Icons.location_on_outlined;
    case Module.customers: return Icons.people_outline;
    case Module.orders: return Icons.assignment_outlined;
    case Module.employees: return Icons.groups_outlined;
    case Module.time: return Icons.schedule_outlined;
    case Module.calendar: return Icons.calendar_month_outlined;
    case Module.reports: return Icons.description_outlined;
    case Module.materials: return Icons.inventory_2_outlined;
    case Module.machines: return Icons.construction_outlined;
    case Module.tasks: return Icons.checklist_outlined;
  }
}

class WorkEntry {
  String title;
  String details;
  String status;
  WorkEntry(this.title, this.details, this.status);
}

class PincusApp extends StatefulWidget {
  const PincusApp({super.key});
  @override State<PincusApp> createState() => _PincusAppState();
}

class _PincusAppState extends State<PincusApp> {
  Module current = Module.dashboard;
  final Map<Module, List<WorkEntry>> entries = {
    for (final module in Module.values) module: <WorkEntry>[],
  };

  void select(Module module) => setState(() => current = module);

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.park_outlined),
            const SizedBox(width: 10),
            Text(moduleLabel(current), style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      body: Row(
        children: [
          if (!mobile) Sidebar(selected: current, onSelect: select),
          Expanded(child: buildPage()),
        ],
      ),
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: current == Module.sites ? 1 : current == Module.customers ? 2 : current == Module.time ? 3 : 0,
              onDestinationSelected: (index) {
                if (index == 1) select(Module.sites);
                else if (index == 2) select(Module.customers);
                else if (index == 3) select(Module.time);
                else select(Module.dashboard);
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Start'),
                NavigationDestination(icon: Icon(Icons.location_on_outlined), label: 'Baustellen'),
                NavigationDestination(icon: Icon(Icons.people_outline), label: 'Kunden'),
                NavigationDestination(icon: Icon(Icons.schedule_outlined), label: 'Zeit'),
              ],
            )
          : null,
    );
  }

  Widget buildPage() {
    if (current == Module.dashboard) {
      return Dashboard(entries: entries, open: select);
    }
    if (current == Module.calendar) {
      return const CalendarPage();
    }
    return ModulePage(
      module: current,
      items: entries[current]!,
      onAdd: (entry) => setState(() => entries[current]!.add(entry)),
      onDelete: (entry) => setState(() => entries[current]!.remove(entry)),
    );
  }
}

class Sidebar extends StatelessWidget {
  final Module selected;
  final ValueChanged<Module> onSelect;
  const Sidebar({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(9),
            child: Image.asset(
              'assets/images/logo.png',
              height: 54,
              errorBuilder: (_, __, ___) => const Icon(Icons.park, color: green, size: 42),
            ),
          ),
          Expanded(
            child: ListView(
              children: Module.values.map((module) {
                final active = selected == module;
                return InkWell(
                  onTap: () => onSelect(module),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? paleGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(moduleIcon(module), size: 26, color: active ? green : Colors.black54),
                        const SizedBox(height: 3),
                        Text(moduleLabel(module), textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final Map<Module, List<WorkEntry>> entries;
  final ValueChanged<Module> open;
  const Dashboard({super.key, required this.entries, required this.open});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 42, 30, 50),
      children: [
        const Text('Pincus Baum und Landschaftspflege', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: darkGreen)),
        const SizedBox(height: 4),
        const Text('Baustellenmanagement & Unternehmensverwaltung', style: TextStyle(fontSize: 17, color: Colors.black54)),
        const SizedBox(height: 28),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            StatCard('Baustellen', Module.sites, Icons.location_on, open, entries),
            StatCard('Kunden', Module.customers, Icons.people, open, entries),
            StatCard('Aufträge', Module.orders, Icons.assignment, open, entries),
            StatCard('Mitarbeiter', Module.employees, Icons.groups, open, entries),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.account_tree_outlined, color: green, size: 30),
                const SizedBox(width: 14),
                const Expanded(child: Text('Kunde → Baustelle → Auftrag → Mitarbeiter → Arbeitszeit', style: TextStyle(fontWeight: FontWeight.w600))),
                FilledButton(onPressed: () => open(Module.orders), child: const Text('Auftrag anlegen')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final Module module;
  final IconData icon;
  final ValueChanged<Module> open;
  final Map<Module, List<WorkEntry>> entries;
  const StatCard(this.label, this.module, this.icon, this.open, this.entries, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        child: InkWell(
          onTap: () => open(module),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: paleGreen, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: green)),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${entries[module]!.length}', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: darkGreen)),
                  const Text('Im System', style: TextStyle(color: Colors.black54)),
                ])),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ModulePage extends StatefulWidget {
  final Module module;
  final List<WorkEntry> items;
  final ValueChanged<WorkEntry> onAdd;
  final ValueChanged<WorkEntry> onDelete;
  const ModulePage({super.key, required this.module, required this.items, required this.onAdd, required this.onDelete});
  @override State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((entry) {
      return '${entry.title} ${entry.details} ${entry.status}'.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 40),
      children: [
        Row(
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: paleGreen, borderRadius: BorderRadius.circular(14)), child: Icon(moduleIcon(widget.module), color: green)),
            const SizedBox(width: 14),
            Expanded(child: Text(moduleLabel(widget.module), style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: darkGreen))),
            FilledButton.icon(onPressed: addEntry, icon: const Icon(Icons.add), label: const Text('Neu')),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) => setState(() => search = value),
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: '${moduleLabel(widget.module)} durchsuchen …', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 12),
        Text('${filtered.length} Einträge', style: const TextStyle(fontWeight: FontWeight.w700, color: darkGreen)),
        const SizedBox(height: 8),
        ...filtered.map((entry) => Card(
          child: ListTile(
            leading: CircleAvatar(backgroundColor: paleGreen, child: Icon(moduleIcon(widget.module), color: green)),
            title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${entry.details}${entry.status.isEmpty ? '' : ' • ${entry.status}'}'),
            trailing: IconButton(onPressed: () => widget.onDelete(entry), icon: const Icon(Icons.delete_outline)),
          ),
        )),
      ],
    );
  }

  Future<void> addEntry() async {
    final entry = await showDialog<WorkEntry>(context: context, builder: (_) => const NewEntryDialog());
    if (entry != null) widget.onAdd(entry);
  }
}

class NewEntryDialog extends StatefulWidget {
  const NewEntryDialog({super.key});
  @override State<NewEntryDialog> createState() => _NewEntryDialogState();
}
class _NewEntryDialogState extends State<NewEntryDialog> {
  final title = TextEditingController();
  final details = TextEditingController();
  String status = 'Neu';
  @override void dispose(){title.dispose();details.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    return AlertDialog(
      title: const Text('Eintrag anlegen'),
      content: SizedBox(width: 560, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Bezeichnung', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: details, maxLines: 4, decoration: const InputDecoration(labelText: 'Details / Notizen', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: status, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()), items: const ['Neu','In Arbeit','Erledigt','Wichtig'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(), onChanged:(x){if(x!=null)setState(()=>status=x);}),
      ])),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: ()=>title.text.trim().isEmpty?null:Navigator.pop(context,WorkEntry(title.text.trim(),details.text.trim(),status)), child: const Text('Speichern')),
      ],
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});
  @override Widget build(BuildContext context){
    final now=DateTime.now();
    return ListView(padding:const EdgeInsets.all(30),children:[
      const Text('Kalender',style:TextStyle(fontSize:29,fontWeight:FontWeight.w700,color:darkGreen)),
      const SizedBox(height:5),
      const Text('Termine und Arbeitszeiten',style:TextStyle(color:Colors.black54)),
      const SizedBox(height:20),
      Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('${now.day.toString().padLeft(2,'0')}.${now.month.toString().padLeft(2,'0')}.${now.year}',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w700)),
        const SizedBox(height:10),
        const Text('Noch keine Termine eingetragen.'),
      ]))),
    ]);
  }
}
