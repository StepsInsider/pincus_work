import 'package:flutter/material.dart';
import 'core/database/app_database.dart';

void main() {
  runApp(const PincusWorkApp());
}

class PincusWorkApp extends StatelessWidget {
  const PincusWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pincus Baum und Landschaftspflege',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const PincusWorkShell(),
    );
  }
}

class PincusWorkShell extends StatefulWidget {
  const PincusWorkShell({super.key});

  @override
  State<PincusWorkShell> createState() => _PincusWorkShellState();
}

class _PincusWorkShellState extends State<PincusWorkShell> {
  final AppDatabase _db = AppDatabase();

  int _selectedIndex = 0;

  final List<_ModuleItem> _modules = const [
    _ModuleItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _ModuleItem(Icons.location_on_outlined, Icons.location_on, 'Baustellen'),
    _ModuleItem(Icons.people_outline, Icons.people, 'Kunden'),
    _ModuleItem(Icons.assignment_outlined, Icons.assignment, 'Aufträge'),
    _ModuleItem(Icons.groups_outlined, Icons.groups, 'Mitarbeiter'),
    _ModuleItem(Icons.schedule_outlined, Icons.schedule, 'Zeiterfassung'),
    _ModuleItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Kalender'),
    _ModuleItem(Icons.request_quote_outlined, Icons.request_quote, 'Angebote'),
    _ModuleItem(Icons.description_outlined, Icons.description, 'Berichte'),
    _ModuleItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Material'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 800;

    final page = _buildPage();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.park, size: 28),
            const SizedBox(width: 10),
            Text(
              _modules[_selectedIndex].label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Benachrichtigungen',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              leading: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(
                color: Color(0xFF2E7D32),
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
              destinations: _modules.map((module) {
                return NavigationRailDestination(
                  icon: Icon(module.icon),
                  selectedIcon: Icon(module.selectedIcon),
                  label: Text(module.label),
                );
              }).toList(),
            ),
          Expanded(child: page),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on),
                  label: 'Baustellen',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Kalender',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule),
                  label: 'Zeit',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.more_horiz),
                  label: 'Mehr',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardPage(db: _db);
      case 1:
        return _DataModulePage(
          title: 'Baustellen',
          icon: Icons.location_on,
          items: _db.sites,
          primaryField: 'title',
          secondaryField: 'address',
          dbLabel: 'Baustellen',
        );
      case 2:
        return _DataModulePage(
          title: 'Kunden',
          icon: Icons.people,
          items: _db.customers,
          primaryField: 'name',
          secondaryField: 'phone',
          dbLabel: 'Kunden',
        );
      case 3:
        return _DataModulePage(
          title: 'Aufträge',
          icon: Icons.assignment,
          items: _db.orders,
          primaryField: 'description',
          secondaryField: 'status',
          dbLabel: 'Aufträge',
        );
      case 4:
        return _DataModulePage(
          title: 'Mitarbeiter',
          icon: Icons.groups,
          items: _db.employees,
          primaryField: 'name',
          secondaryField: 'role',
          dbLabel: 'Mitarbeiter',
        );
      case 5:
        return _DataModulePage(
          title: 'Zeiterfassung',
          icon: Icons.schedule,
          items: _db.timeEntries,
          primaryField: 'employee',
          secondaryField: 'task',
          dbLabel: 'Zeiteinträge',
        );
      case 6:
        return const CalendarFeatureScreen();
      case 7:
        return _DataModulePage(
          title: 'Angebote',
          icon: Icons.request_quote,
          items: _db.estimates,
          primaryField: 'title',
          secondaryField: 'customer',
          dbLabel: 'Angebote',
        );
      case 8:
        return _DataModulePage(
          title: 'Berichte',
          icon: Icons.description,
          items: _db.reports,
          primaryField: 'title',
          secondaryField: 'date',
          dbLabel: 'Berichte',
        );
      case 9:
        return _DataModulePage(
          title: 'Material',
          icon: Icons.inventory_2,
          items: _db.materials,
          primaryField: 'name',
          secondaryField: 'category',
          dbLabel: 'Material',
        );
      default:
        return _DashboardPage(db: _db);
    }
  }
}

class _ModuleItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _ModuleItem(this.icon, this.selectedIcon, this.label);
}

class _DashboardPage extends StatelessWidget {
  final AppDatabase db;

  const _DashboardPage({required this.db});

  @override
  Widget build(BuildContext context) {
    final totalHours = db.timeEntries.fold<double>(
      0,
      (sum, entry) {
        final value = double.tryParse('${entry['hours']}') ?? 0;
        return sum + value;
      },
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pincus Baum und Landschaftspflege',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Baustellenmanagement & Unternehmensverwaltung',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 650
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.1,
                children: [
                  _StatCard(
                    icon: Icons.location_on,
                    title: 'Baustellen',
                    value: '${db.sites.length}',
                    subtitle: 'Aktive Standorte',
                  ),
                  _StatCard(
                    icon: Icons.people,
                    title: 'Kunden',
                    value: '${db.customers.length}',
                    subtitle: 'Kunden im System',
                  ),
                  _StatCard(
                    icon: Icons.groups,
                    title: 'Mitarbeiter',
                    value: '${db.employees.length}',
                    subtitle: 'Teammitglieder',
                  ),
                  _StatCard(
                    icon: Icons.schedule,
                    title: 'Arbeitsstunden',
                    value: totalHours.toStringAsFixed(1),
                    subtitle: 'Erfasste Stunden',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [
                    _UpcomingEvents(db: db),
                    const SizedBox(height: 16),
                    _QuickActions(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _UpcomingEvents(db: db)),
                  const SizedBox(width: 16),
                  Expanded(child: _QuickActions()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingEvents extends StatelessWidget {
  final AppDatabase db;

  const _UpcomingEvents({required this.db});

  @override
  Widget build(BuildContext context) {
    final events = db.calendarEvents;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Nächste Termine',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (events.isEmpty)
              const Text('Keine Termine vorhanden.')
            else
              ...events.take(4).map(
                    (event) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.work,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      title: Text('${event['title']}'),
                      subtitle: Text(
                        '${event['date']} • ${event['time']} • ${event['assigned']}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flash_on, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Schnellzugriff',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.add_business,
              title: 'Neue Baustelle',
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.person_add,
              title: 'Neuen Kunden anlegen',
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.timer,
              title: 'Arbeitszeit erfassen',
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.request_quote,
              title: 'Angebot erstellen',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DataModulePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> items;
  final String primaryField;
  final String secondaryField;
  final String dbLabel;

  const _DataModulePage({
    required this.title,
    required this.icon,
    required this.items,
    required this.primaryField,
    required this.secondaryField,
    required this.dbLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32), size: 30),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: Text('Neu'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${items.length} $dbLabel im lokalen Datenbestand',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(icon, size: 48, color: Colors.black26),
                      const SizedBox(height: 12),
                      Text('Noch keine $dbLabel vorhanden.'),
                    ],
                  ),
                ),
              ),
            )
          else
            ...items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Icon(
                      icon,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  title: Text(
                    '${item[primaryField] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item[secondaryField] ?? ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CalendarFeatureScreen extends StatefulWidget {
  const CalendarFeatureScreen({super.key});

  @override
  State<CalendarFeatureScreen> createState() => _CalendarFeatureScreenState();
}

class _CalendarFeatureScreenState extends State<CalendarFeatureScreen> {
  final AppDatabase _db = AppDatabase();
  int _selectedMonth = 9;

  @override
  Widget build(BuildContext context) {
    final months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    
    final daysInMonth = List.generate(
      DateTime(2026, _selectedMonth + 1, 0).day, 
      (i) => DateTime(2026, _selectedMonth, i + 1)
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jahreskalender & Einsatzübersicht 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: const Color(0xFF2E7D32)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(12, (index) {
                  final monthNum = index + 1;
                  final isSelected = _selectedMonth == monthNum;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(months[index]),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      onSelected: (selected) {
                        setState(() {
                          _selectedMonth = monthNum;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text('Monatsansicht: ${months[_selectedMonth - 1]} 2026 – Klicken Sie auf einen Tag für Details:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: daysInMonth.length,
                itemBuilder: (context, index) {
                  final date = daysInMonth[index];
                  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  
                  final dayEvents = _db.calendarEvents.where((e) => e['date'] == dateStr).toList();
                  final dayTimes = _db.timeEntries.where((t) => t['date'] == dateStr).toList();
                  bool hasActivity = dayEvents.isNotEmpty || dayTimes.isNotEmpty;

                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Einsätze & Details am ${date.day}.${date.month}.${date.year}'),
                          content: SizedBox(
                            width: 400,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Geplante Termine / Baustellen:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                if (dayEvents.isEmpty) const Text('• Keine Termine an diesem Tag'),
                                ...dayEvents.map((e) => Text('• ${e["title"]} (Zuständig: ${e["assigned"]})')),
                                const SizedBox(height: 16),
                                const Text('Erfasste Arbeitsstunden:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                if (dayTimes.isEmpty) const Text('• Keine Stunden erfasst'),
                                ...dayTimes.map((t) => Text('• Mitarbeiter: ${t["employee"]} | ${t["task"]} | ${t["hours"]} Std.')),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Schließen'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: hasActivity ? const Color(0xFFC8E6C9) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: hasActivity ? const Color(0xFF2E7D32) : Colors.grey.shade300, width: hasActivity ? 2 : 1),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${date.day}.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: hasActivity ? const Color(0xFF1B5E20) : Colors.black87)),
                          if (hasActivity)
                            Row(
                              children: [
                                const Icon(Icons.work, size: 12, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 4),
                                Text('${dayEvents.length + dayTimes.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                              ],
                            )
                          else
                            const Text('-', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
