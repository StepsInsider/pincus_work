import 'package:flutter/material.dart';
import 'core/database/app_database.dart';
import 'pincus_workspace_v2.dart' show WorkModule, ModuleView, CalendarView, Watermark, WorkSidebar, title, icon, kGreen, kDarkGreen, kPaleGreen, kBg;

class PincusWorkspaceV3 extends StatefulWidget {
  const PincusWorkspaceV3({super.key});

  @override
  State<PincusWorkspaceV3> createState() => _PincusWorkspaceV3State();
}

class _PincusWorkspaceV3State extends State<PincusWorkspaceV3> {
  final db = AppDatabase();
  WorkModule module = WorkModule.dashboard;

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.park_outlined),
            const SizedBox(width: 10),
            Text(title(module), style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (!mobile)
            WorkSidebar(
              selected: module,
              onSelect: (m) => setState(() => module = m),
            ),
          Expanded(child: _page()),
        ],
      ),
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: _mobileIndex(module),
              onDestinationSelected: (i) => setState(() => module = _mobileModule(i)),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Start'),
                NavigationDestination(icon: Icon(Icons.location_on_outlined), label: 'Baustellen'),
                NavigationDestination(icon: Icon(Icons.people_outline), label: 'Kunden'),
                NavigationDestination(icon: Icon(Icons.schedule_outlined), label: 'Zeit'),
                NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mehr'),
              ],
            )
          : null,
    );
  }

  Widget _page() => switch (module) {
        WorkModule.dashboard => WorkflowDashboard(
            db: db,
            onOpen: (m) => setState(() => module = m),
          ),
        WorkModule.calendar => CalendarView(db: db),
        _ => ModuleView(db: db, kind: module),
      };

  int _mobileIndex(WorkModule m) => switch (m) {
        WorkModule.sites => 1,
        WorkModule.customers => 2,
        WorkModule.time => 3,
        _ => 0,
      };

  WorkModule _mobileModule(int i) => switch (i) {
        1 => WorkModule.sites,
        2 => WorkModule.customers,
        3 => WorkModule.time,
        _ => WorkModule.dashboard,
      };
}

class WorkflowDashboard extends StatelessWidget {
  final AppDatabase db;
  final ValueChanged<WorkModule> onOpen;

  const WorkflowDashboard({super.key, required this.db, required this.onOpen});

  Future<List<int>> _counts() async => [
        (await db.select(db.customers).get()).length,
        (await db.select(db.sites).get()).length,
        (await db.select(db.orders).get()).length,
        (await db.select(db.employees).get()).length,
        (await db.select(db.timeEntries).get()).length,
        (await db.select(db.reports).get()).length,
      ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Watermark(),
        FutureBuilder<List<int>>(
          future: _counts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: kGreen));
            }
            final c = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
              children: [
                const Text(
                  'Pincus Baum und Landschaftspflege',
                  style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: kDarkGreen),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Baustellenmanagement & Unternehmensverwaltung',
                  style: TextStyle(fontSize: 17, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                _StatsGrid(counts: c, onOpen: onOpen),
                const SizedBox(height: 22),
                _SectionCard(
                  title: 'Arbeitsablauf',
                  subtitle: 'Von der Anfrage bis zur dokumentierten Arbeitsleistung',
                  child: _WorkflowSteps(onOpen: onOpen),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 850;
                    final children = [
                      _QuickActions(onOpen: onOpen),
                      _OverviewCard(counts: c, onOpen: onOpen),
                    ];
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: children[0]),
                          const SizedBox(width: 16),
                          Expanded(child: children[1]),
                        ],
                      );
                    }
                    return Column(children: [children[0], const SizedBox(height: 16), children[1]]);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<int> counts;
  final ValueChanged<WorkModule> onOpen;

  const _StatsGrid({required this.counts, required this.onOpen});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          _Stat(label: 'Kunden', value: counts[0], caption: 'Stammdaten', iconData: Icons.people, module: WorkModule.customers, onOpen: onOpen),
          _Stat(label: 'Baustellen', value: counts[1], caption: 'Standorte', iconData: Icons.location_on, module: WorkModule.sites, onOpen: onOpen),
          _Stat(label: 'Aufträge', value: counts[2], caption: 'Vorgänge', iconData: Icons.assignment, module: WorkModule.orders, onOpen: onOpen),
          _Stat(label: 'Mitarbeiter', value: counts[3], caption: 'Team', iconData: Icons.groups, module: WorkModule.employees, onOpen: onOpen),
        ],
      );
}

class _Stat extends StatelessWidget {
  final String label, caption;
  final int value;
  final IconData iconData;
  final WorkModule module;
  final ValueChanged<WorkModule> onOpen;

  const _Stat({required this.label, required this.value, required this.caption, required this.iconData, required this.module, required this.onOpen});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 285,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onOpen(module),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: kPaleGreen, borderRadius: BorderRadius.circular(14)),
                    child: Icon(iconData, color: kGreen),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('$value', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: kGreen)),
                      Text(caption, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _WorkflowSteps extends StatelessWidget {
  final ValueChanged<WorkModule> onOpen;
  const _WorkflowSteps({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (WorkModule.customers, '1', 'Kunde', 'Stammdaten erfassen', Icons.person_add_alt_1_outlined),
      (WorkModule.sites, '2', 'Baustelle', 'Standort zuordnen', Icons.location_on_outlined),
      (WorkModule.orders, '3', 'Auftrag', 'Leistung und Preis', Icons.assignment_outlined),
      (WorkModule.employees, '4', 'Mitarbeiter', 'Team auswählen', Icons.groups_outlined),
      (WorkModule.time, '5', 'Arbeitszeit', 'Leistung dokumentieren', Icons.schedule_outlined),
      (WorkModule.reports, '6', 'Bericht', 'Arbeit abschließen', Icons.description_outlined),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final s in steps)
          SizedBox(
            width: 245,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onOpen(s.$1),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPaleGreen),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 19, backgroundColor: kPaleGreen, child: Text(s.$2, style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.w800))),
                    const SizedBox(width: 10),
                    Icon(s.$5, size: 22, color: kGreen),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.$3, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(s.$4, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final ValueChanged<WorkModule> onOpen;
  const _QuickActions({required this.onOpen});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'Schnellzugriff',
        subtitle: 'Die wichtigsten Vorgänge direkt öffnen',
        child: Column(
          children: [
            _Action(label: 'Neuer Kunde', iconData: Icons.person_add_outlined, module: WorkModule.customers, onOpen: onOpen),
            _Action(label: 'Neue Baustelle', iconData: Icons.add_location_alt_outlined, module: WorkModule.sites, onOpen: onOpen),
            _Action(label: 'Neuer Auftrag', iconData: Icons.post_add_outlined, module: WorkModule.orders, onOpen: onOpen),
            _Action(label: 'Arbeitszeit erfassen', iconData: Icons.timer_outlined, module: WorkModule.time, onOpen: onOpen),
            _Action(label: 'Bericht erstellen', iconData: Icons.note_add_outlined, module: WorkModule.reports, onOpen: onOpen),
          ],
        ),
      );
}

class _Action extends StatelessWidget {
  final String label;
  final IconData iconData;
  final WorkModule module;
  final ValueChanged<WorkModule> onOpen;
  const _Action({required this.label, required this.iconData, required this.module, required this.onOpen});

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        leading: Icon(iconData, color: kGreen),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onOpen(module),
      );
}

class _OverviewCard extends StatelessWidget {
  final List<int> counts;
  final ValueChanged<WorkModule> onOpen;
  const _OverviewCard({required this.counts, required this.onOpen});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'Systemübersicht',
        subtitle: 'Erfasste Vorgänge',
        child: Column(
          children: [
            _OverviewRow('Arbeitszeiten', counts[4], Icons.schedule_outlined, WorkModule.time),
            _OverviewRow('Berichte', counts[5], Icons.description_outlined, WorkModule.reports),
            _OverviewRow('Material', null, Icons.inventory_2_outlined, WorkModule.materials),
            _OverviewRow('Maschinen', null, Icons.construction_outlined, WorkModule.machines),
            _OverviewRow('Aufgaben', null, Icons.checklist_outlined, WorkModule.tasks),
          ].map((w) => _rowWithCallback(w)).toList(),
        ),
      );

  Widget _rowWithCallback(_OverviewRow row) => ListTile(
        dense: true,
        leading: Icon(row.iconData, color: kGreen),
        title: Text(row.label),
        trailing: row.value == null ? const Icon(Icons.chevron_right) : Text('${row.value}', style: const TextStyle(fontWeight: FontWeight.w800, color: kGreen)),
        onTap: () => onOpen(row.module),
      );
}

class _OverviewRow {
  final String label;
  final int? value;
  final IconData iconData;
  final WorkModule module;
  const _OverviewRow(this.label, this.value, this.iconData, this.module);
}

class _SectionCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _SectionCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kDarkGreen)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      );
}
