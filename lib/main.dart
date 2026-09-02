import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'core/database/app_database.dart';

const _green = Color(0xFF2E7D32);
const _darkGreen = Color(0xFF1B5E20);
const _lightGreen = Color(0xFFE8F5E9);
const _pageBg = Color(0xFFF6F8F5);

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
        scaffoldBackgroundColor: _pageBg,
        colorScheme: ColorScheme.fromSeed(seedColor: _green),
        fontFamily: 'Arial',
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black.withValues(alpha: .06)),
          ),
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

  static const _modules = [
    _Module(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _Module(Icons.location_on_outlined, Icons.location_on, 'Baustellen'),
    _Module(Icons.people_outline, Icons.people, 'Kunden'),
    _Module(Icons.assignment_outlined, Icons.assignment, 'Aufträge'),
    _Module(Icons.groups_outlined, Icons.groups, 'Mitarbeiter'),
    _Module(Icons.schedule_outlined, Icons.schedule, 'Zeiterfassung'),
    _Module(Icons.calendar_month_outlined, Icons.calendar_month, 'Kalender'),
    _Module(Icons.description_outlined, Icons.description, 'Berichte'),
    _Module(Icons.inventory_2_outlined, Icons.inventory_2, 'Material'),
    _Module(Icons.construction_outlined, Icons.construction, 'Maschinen'),
  ];

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: AppBar(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 18,
          title: Row(
            children: [
              const Icon(Icons.park_outlined, size: 30),
              const SizedBox(width: 10),
              Text(
                _modules[_selectedIndex].label,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Benachrichtigungen',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, size: 27),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: Row(
        children: [
          if (!mobile)
            _Sidebar(
              modules: _modules,
              selectedIndex: _selectedIndex,
              onSelected: (i) => setState(() => _selectedIndex = i),
            ),
          Expanded(child: _buildPage()),
        ],
      ),
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: _selectedIndex < 5 ? _selectedIndex : 0,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'Baustellen'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Kunden'),
                NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Zeit'),
                NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mehr'),
              ],
            )
          : null,
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardPage(db: _db, onOpenModule: (i) => setState(() => _selectedIndex = i));
      case 1:
        return _DataModulePage(db: _db, config: _ModuleConfig.sites());
      case 2:
        return _DataModulePage(db: _db, config: _ModuleConfig.customers());
      case 3:
        return _DataModulePage(db: _db, config: _ModuleConfig.orders());
      case 4:
        return _DataModulePage(db: _db, config: _ModuleConfig.employees());
      case 5:
        return _DataModulePage(db: _db, config: _ModuleConfig.timeEntries());
      case 6:
        return const CalendarFeatureScreen();
      case 7:
        return _DataModulePage(db: _db, config: _ModuleConfig.reports());
      case 8:
        return _DataModulePage(db: _db, config: _ModuleConfig.materials());
      case 9:
        return _DataModulePage(db: _db, config: _ModuleConfig.machines());
      default:
        return _DashboardPage(db: _db, onOpenModule: (i) => setState(() => _selectedIndex = i));
    }
  }
}

class _Module {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Module(this.icon, this.selectedIcon, this.label);
}

class _Sidebar extends StatelessWidget {
  final List<_Module> modules;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _Sidebar({required this.modules, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Image.asset('assets/images/logo.png', height: 50, fit: BoxFit.contain),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              itemCount: modules.length,
              itemBuilder: (context, i) {
                final selected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onSelected(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? _lightGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(selected ? modules[i].selectedIcon : modules[i].icon, size: 27, color: selected ? _green : Colors.black54),
                          const SizedBox(height: 3),
                          Text(
                            modules[i].label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: selected ? _darkGreen : Colors.black87,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Opacity(
              opacity: .75,
              child: Image.asset('assets/images/logo.png', height: 55, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  final AppDatabase db;
  final ValueChanged<int> onOpenModule;
  const _DashboardPage({required this.db, required this.onOpenModule});

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  late Future<DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DashboardData> _load() async {
    final sites = await widget.db.select(widget.db.sites).get();
    final customers = await widget.db.select(widget.db.customers).get();
    final employees = await widget.db.select(widget.db.employees).get();
    final entries = await widget.db.select(widget.db.timeEntries).get();
    final hours = entries.fold<double>(0, (sum, e) {
      if (e.endTime == null) return sum;
      final minutes = e.endTime!.difference(e.startTime).inMinutes - e.breakMinutes.round();
      return sum + (minutes.clamp(0, 100000) / 60);
    });
    return DashboardData(sites.length, customers.length, employees.length, hours);
  }

  void refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _Watermark(),
        FutureBuilder<DashboardData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _green));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Fehler beim Laden der Daten: ${snapshot.error}'));
            }
            final data = snapshot.data ?? DashboardData.empty();
            return RefreshIndicator(
              color: _green,
              onRefresh: () async => refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(30, 28, 30, 34),
                children: [
                  const Text('Pincus Baum und Landschaftspflege', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: _darkGreen)),
                  const SizedBox(height: 4),
                  const Text('Baustellenmanagement & Unternehmensverwaltung', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, c) {
                      final count = c.maxWidth > 1050 ? 2 : 1;
                      return GridView.count(
                        crossAxisCount: count,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: count == 2 ? 2.55 : 3.4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _StatCard(icon: Icons.location_on, title: 'Baustellen', value: '${data.sites}', subtitle: 'Aktive Standorte', onTap: () => widget.onOpenModule(1)),
                          _StatCard(icon: Icons.people, title: 'Kunden', value: '${data.customers}', subtitle: 'Kunden im System', onTap: () => widget.onOpenModule(2)),
                          _StatCard(icon: Icons.groups, title: 'Mitarbeiter', value: '${data.employees}', subtitle: 'Teammitglieder', onTap: () => widget.onOpenModule(4)),
                          _StatCard(icon: Icons.schedule, title: 'Arbeitsstunden', value: data.hours.toStringAsFixed(1), subtitle: 'Erfasste Stunden', onTap: () => widget.onOpenModule(5)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [Icon(Icons.flash_on, color: _green), SizedBox(width: 8), Text('Schnellzugriff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]),
                          _QuickAction(icon: Icons.add_business, title: 'Neue Baustelle', onTap: () => widget.onOpenModule(1)),
                          _QuickAction(icon: Icons.person_add, title: 'Neuen Kunden anlegen', onTap: () => widget.onOpenModule(2)),
                          _QuickAction(icon: Icons.timer, title: 'Arbeitszeit erfassen', onTap: () => widget.onOpenModule(5)),
                          _QuickAction(icon: Icons.assignment_add, title: 'Neuen Auftrag anlegen', onTap: () => widget.onOpenModule(3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class DashboardData {
  final int sites;
  final int customers;
  final int employees;
  final double hours;
  const DashboardData(this.sites, this.customers, this.employees, this.hours);
  factory DashboardData.empty() => const DashboardData(0, 0, 0, 0);
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const _StatCard({required this.icon, required this.title, required this.value, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: _green, size: 29),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: _darkGreen)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ]),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: _green),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
}

class _Watermark extends StatelessWidget {
  const _Watermark();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.center,
        child: Opacity(
          opacity: .055,
          child: Icon(Icons.park, size: 600, color: _green),
        ),
      ),
    );
  }
}

enum _ModuleType { sites, customers, orders, employees, timeEntries, reports, materials, machines }

class _ModuleConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final _ModuleType type;
  final List<_FieldDef> fields;

  const _ModuleConfig({required this.title, required this.subtitle, required this.icon, required this.type, required this.fields});

  factory _ModuleConfig.sites() => const _ModuleConfig(
        title: 'Baustellen', subtitle: 'Baustellen und Einsatzorte verwalten', icon: Icons.location_on, type: _ModuleType.sites,
        fields: [_FieldDef('title', 'Bezeichnung', required: true), _FieldDef('address', 'Adresse', required: true), _FieldDef('customerId', 'Kunden-ID')],
      );

  factory _ModuleConfig.customers() => const _ModuleConfig(
        title: 'Kunden', subtitle: 'Kontakte und Kundendaten verwalten', icon: Icons.people, type: _ModuleType.customers,
        fields: [_FieldDef('name', 'Name / Firma', required: true), _FieldDef('contact', 'Ansprechpartner'), _FieldDef('phone', 'Telefon'), _FieldDef('address', 'Adresse')],
      );

  factory _ModuleConfig.orders() => const _ModuleConfig(
        title: 'Aufträge', subtitle: 'Aufträge, Status, Termine und Preise', icon: Icons.assignment, type: _ModuleType.orders,
        fields: [_FieldDef('title', 'Auftragsbezeichnung', required: true), _FieldDef('customerId', 'Kunden-ID'), _FieldDef('siteId', 'Baustellen-ID'), _FieldDef('status', 'Status', initial: 'Neu'), _FieldDef('date', 'Termin / Datum', required: true), _FieldDef('price', 'Preis', keyboard: TextInputType.number)],
      );

  factory _ModuleConfig.employees() => const _ModuleConfig(
        title: 'Mitarbeiter', subtitle: 'Team, Rollen und Sollstunden', icon: Icons.groups, type: _ModuleType.employees,
        fields: [_FieldDef('name', 'Name', required: true), _FieldDef('role', 'Rolle / Tätigkeit', required: true), _FieldDef('targetHours', 'Sollstunden / Woche', keyboard: TextInputType.number, initial: '40')],
      );

  factory _ModuleConfig.timeEntries() => const _ModuleConfig(
        title: 'Zeiterfassung', subtitle: 'Arbeitszeiten und Pausen dokumentieren', icon: Icons.schedule, type: _ModuleType.timeEntries,
        fields: [_FieldDef('employeeName', 'Mitarbeiter', required: true), _FieldDef('siteId', 'Baustellen-ID', required: true), _FieldDef('date', 'Datum', required: true), _FieldDef('startTime', 'Beginn', required: true), _FieldDef('endTime', 'Ende'), _FieldDef('breakMinutes', 'Pause in Minuten', keyboard: TextInputType.number, initial: '0'), _FieldDef('notes', 'Notizen')],
      );

  factory _ModuleConfig.reports() => const _ModuleConfig(
        title: 'Berichte', subtitle: 'Baustellenberichte dokumentieren', icon: Icons.description, type: _ModuleType.reports,
        fields: [_FieldDef('title', 'Titel', required: true), _FieldDef('siteId', 'Baustellen-ID'), _FieldDef('date', 'Datum', required: true), _FieldDef('content', 'Bericht / Inhalt', multiline: true)],
      );

  factory _ModuleConfig.materials() => const _ModuleConfig(
        title: 'Material', subtitle: 'Materialbestand und Artikel verwalten', icon: Icons.inventory_2, type: _ModuleType.materials,
        fields: [_FieldDef('name', 'Material / Artikel', required: true), _FieldDef('articleNumber', 'Artikelnummer'), _FieldDef('category', 'Kategorie'), _FieldDef('unit', 'Einheit', initial: 'Stk'), _FieldDef('stock', 'Bestand', keyboard: TextInputType.number, initial: '0'), _FieldDef('minimumStock', 'Mindestbestand', keyboard: TextInputType.number, initial: '0'), _FieldDef('location', 'Lagerort'), _FieldDef('unitPrice', 'Einzelpreis', keyboard: TextInputType.number), _FieldDef('notes', 'Notizen', multiline: true)],
      );

  factory _ModuleConfig.machines() => const _ModuleConfig(
        title: 'Maschinen', subtitle: 'Maschinen, Betriebsstunden und Prüfungen', icon: Icons.construction, type: _ModuleType.machines,
        fields: [_FieldDef('name', 'Maschine', required: true), _FieldDef('serialNumber', 'Seriennummer'), _FieldDef('operatingHours', 'Betriebsstunden', keyboard: TextInputType.number, initial: '0'), _FieldDef('status', 'Status', initial: 'bereit'), _FieldDef('notes', 'Notizen', multiline: true)],
      );
}

class _FieldDef {
  final String key;
  final String label;
  final bool required;
  final TextInputType? keyboard;
  final String? initial;
  final bool multiline;

  const _FieldDef(this.key, this.label, {this.required = false, this.keyboard, this.initial, this.multiline = false});
}

class _DataModulePage extends StatefulWidget {
  final AppDatabase db;
  final _ModuleConfig config;
  const _DataModulePage({required this.db, required this.config});

  @override
  State<_DataModulePage> createState() => _DataModulePageState();
}

class _DataModulePageState extends State<_DataModulePage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    switch (widget.config.type) {
      case _ModuleType.sites: return widget.db.select(widget.db.sites).get();
      case _ModuleType.customers: return widget.db.select(widget.db.customers).get();
      case _ModuleType.orders: return widget.db.select(widget.db.orders).get();
      case _ModuleType.employees: return widget.db.select(widget.db.employees).get();
      case _ModuleType.timeEntries: return widget.db.select(widget.db.timeEntries).get();
      case _ModuleType.reports: return widget.db.select(widget.db.reports).get();
      case _ModuleType.materials: return widget.db.select(widget.db.materialsTable).get();
      case _ModuleType.machines: return widget.db.select(widget.db.machinesTable).get();
    }
  }

  void refresh() => setState(() => _future = _load());

  Future<void> _create() async {
    final values = await showDialog<Map<String, String>>(context: context, builder: (_) => _EntryDialog(config: widget.config));
    if (values == null) return;
    try {
      await _insert(values);
      refresh();
      if (mounted) _snack('${widget.config.title}: Eintrag gespeichert.');
    } catch (e) {
      if (mounted) _snack('Speichern fehlgeschlagen: $e', error: true);
    }
  }

  Future<void> _edit(dynamic item) async {
    final values = await showDialog<Map<String, String>>(context: context, builder: (_) => _EntryDialog(config: widget.config, initial: _toMap(item)));
    if (values == null) return;
    try {
      await _update(item, values);
      refresh();
      if (mounted) _snack('Änderungen gespeichert.');
    } catch (e) {
      if (mounted) _snack('Ändern fehlgeschlagen: $e', error: true);
    }
  }

  Future<void> _delete(dynamic item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Der Datensatz wird dauerhaft aus der lokalen Datenbank entfernt.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700), onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _deleteFromDb(item);
      refresh();
      if (mounted) _snack('Eintrag gelöscht.');
    } catch (e) {
      if (mounted) _snack('Löschen fehlgeschlagen: $e', error: true);
    }
  }

  Future<void> _insert(Map<String, String> v) async {
    switch (widget.config.type) {
      case _ModuleType.sites:
        await widget.db.into(widget.db.sites).insert(SitesCompanion.insert(title: v['title']!, address: v['address']!, customerId: _text(v['customerId'])));
      case _ModuleType.customers:
        await widget.db.into(widget.db.customers).insert(CustomersCompanion.insert(id: _id(), name: v['name']!, contact: Value(v['contact'] ?? ''), phone: Value(v['phone'] ?? ''), address: Value(v['address'] ?? '')));
      case _ModuleType.orders:
        await widget.db.into(widget.db.orders).insert(OrdersCompanion.insert(id: _id(), siteId: _int(v['siteId']), customerId: _text(v['customerId']), title: v['title']!, status: Value(v['status'] ?? 'Neu'), date: v['date']!, price: Value(_number(v['price']))));
      case _ModuleType.employees:
        await widget.db.into(widget.db.employees).insert(EmployeesCompanion.insert(id: _id(), name: v['name']!, role: v['role']!, targetHours: Value(_number(v['targetHours'] ?? '40'))));
      case _ModuleType.timeEntries:
        final date = _parseDate(v['date']!);
        final start = _parseDateTime(v['date']!, v['startTime']!);
        final end = (v['endTime'] ?? '').trim().isEmpty ? null : _parseDateTime(v['date']!, v['endTime']!);
        await widget.db.into(widget.db.timeEntries).insert(TimeEntriesCompanion.insert(siteId: int.parse(v['siteId']!), employeeName: v['employeeName']!, date: date, startTime: start, endTime: Value(end), breakMinutes: Value(_number(v['breakMinutes'])), notes: Value(_textValue(v['notes']))));
      case _ModuleType.reports:
        await widget.db.into(widget.db.reports).insert(ReportsCompanion.insert(id: _id(), siteId: _int(v['siteId']), title: v['title']!, date: v['date']!, content: v['content'] ?? ''));
      case _ModuleType.materials:
        await widget.db.into(widget.db.materialsTable).insert(MaterialsTableCompanion.insert(name: v['name']!, articleNumber: Value(_textValue(v['articleNumber'])), category: Value(_textValue(v['category'])), unit: Value(v['unit'] ?? 'Stk'), stock: Value(_number(v['stock'])), minimumStock: Value(_number(v['minimumStock'])), location: Value(_textValue(v['location'])), unitPrice: Value(_nullableNumber(v['unitPrice'])), notes: Value(_textValue(v['notes']))));
      case _ModuleType.machines:
        await widget.db.into(widget.db.machinesTable).insert(MachinesTableCompanion.insert(name: v['name']!, serialNumber: Value(_textValue(v['serialNumber'])), operatingHours: Value(_number(v['operatingHours'])), status: Value(v['status'] ?? 'bereit'), notes: Value(_textValue(v['notes']))));
    }
  }

  Future<void> _update(dynamic item, Map<String, String> v) async {
    switch (widget.config.type) {
      case _ModuleType.sites:
        await (widget.db.update(widget.db.sites)..where((t) => t.id.equals(item.id))).write(SitesCompanion(title: Value(v['title']!), address: Value(v['address']!), customerId: _text(v['customerId'])));
      case _ModuleType.customers:
        await (widget.db.update(widget.db.customers)..where((t) => t.id.equals(item.id))).write(CustomersCompanion(name: Value(v['name']!), contact: Value(v['contact'] ?? ''), phone: Value(v['phone'] ?? ''), address: Value(v['address'] ?? '')));
      case _ModuleType.orders:
        await (widget.db.update(widget.db.orders)..where((t) => t.id.equals(item.id))).write(OrdersCompanion(title: Value(v['title']!), customerId: _text(v['customerId']), siteId: _int(v['siteId']), status: Value(v['status'] ?? 'Neu'), date: Value(v['date']!), price: Value(_number(v['price']))));
      case _ModuleType.employees:
        await (widget.db.update(widget.db.employees)..where((t) => t.id.equals(item.id))).write(EmployeesCompanion(name: Value(v['name']!), role: Value(v['role']!), targetHours: Value(_number(v['targetHours']))));
      case _ModuleType.timeEntries:
        final date = _parseDate(v['date']!);
        final start = _parseDateTime(v['date']!, v['startTime']!);
        final end = (v['endTime'] ?? '').trim().isEmpty ? null : _parseDateTime(v['date']!, v['endTime']!);
        await (widget.db.update(widget.db.timeEntries)..where((t) => t.id.equals(item.id))).write(TimeEntriesCompanion(date: Value(date), startTime: Value(start), endTime: Value(end), employeeName: Value(v['employeeName']!), siteId: Value(int.parse(v['siteId']!)), breakMinutes: Value(_number(v['breakMinutes'])), notes: Value(_textValue(v['notes']))));
      case _ModuleType.reports:
        await (widget.db.update(widget.db.reports)..where((t) => t.id.equals(item.id))).write(ReportsCompanion(title: Value(v['title']!), siteId: _int(v['siteId']), date: Value(v['date']!), content: Value(v['content'] ?? '')));
      case _ModuleType.materials:
        await (widget.db.update(widget.db.materialsTable)..where((t) => t.id.equals(item.id))).write(MaterialsTableCompanion(name: Value(v['name']!), articleNumber: Value(_textValue(v['articleNumber'])), category: Value(_textValue(v['category'])), unit: Value(v['unit'] ?? 'Stk'), stock: Value(_number(v['stock'])), minimumStock: Value(_number(v['minimumStock'])), location: Value(_textValue(v['location'])), unitPrice: Value(_nullableNumber(v['unitPrice'])), notes: Value(_textValue(v['notes'])), updatedAt: Value(DateTime.now())));
      case _ModuleType.machines:
        await (widget.db.update(widget.db.machinesTable)..where((t) => t.id.equals(item.id))).write(MachinesTableCompanion(name: Value(v['name']!), serialNumber: Value(_textValue(v['serialNumber'])), operatingHours: Value(_number(v['operatingHours'])), status: Value(v['status'] ?? 'bereit'), notes: Value(_textValue(v['notes']))));
    }
  }

  Future<void> _deleteFromDb(dynamic item) async {
    switch (widget.config.type) {
      case _ModuleType.sites: await (widget.db.delete(widget.db.sites)..where((t) => t.id.equals(item.id))).go();
      case _ModuleType.customers: await (widget.db.delete(widget.db.customers)..where((t) => t.id.equals(item.id))).go();
      case _ModuleType.orders: await (widget.db.delete(widget.db.orders)..where((t) => t.id.equals(item.id))).go();
      case _ModuleType.employees: await (widget.db.delete(widget.db.employees)..where((t) => t.id.equals(item.id))).go();
      case _ModuleType.timeEntries: await (widget.db.delete(widget.db.timeEntries)..where((t) => t.id.equals(item.id))).go();
      case _ModuleType.reports: await (widget.db.delete(widget.db.reports)..where((t) => t.id.equals(item.id))).go();
      case _ModuleType.materials: await (widget.db.delete(widget.db.materialsTable)..where((t) => t.id.equals(item.id))).go();
      case _ModuleType.machines: await (widget.db.delete(widget.db.machinesTable)..where((t) => t.id.equals(item.id))).go();
    }
  }

  Map<String, String> _toMap(dynamic item) {
    switch (widget.config.type) {
      case _ModuleType.sites: return {'title': item.title, 'address': item.address, 'customerId': item.customerId ?? ''};
      case _ModuleType.customers: return {'name': item.name, 'contact': item.contact, 'phone': item.phone, 'address': item.address};
      case _ModuleType.orders: return {'title': item.title, 'customerId': item.customerId ?? '', 'siteId': item.siteId?.toString() ?? '', 'status': item.status, 'date': item.date, 'price': item.price.toString()};
      case _ModuleType.employees: return {'name': item.name, 'role': item.role, 'targetHours': item.targetHours.toString()};
      case _ModuleType.timeEntries:
        String fmtDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        String fmtTime(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
        return {'employeeName': item.employeeName, 'siteId': item.siteId.toString(), 'date': fmtDate(item.date), 'startTime': fmtTime(item.startTime), 'endTime': item.endTime == null ? '' : fmtTime(item.endTime!), 'breakMinutes': item.breakMinutes.toString(), 'notes': item.notes ?? ''};
      case _ModuleType.reports: return {'title': item.title, 'siteId': item.siteId?.toString() ?? '', 'date': item.date, 'content': item.content};
      case _ModuleType.materials: return {'name': item.name, 'articleNumber': item.articleNumber ?? '', 'category': item.category ?? '', 'unit': item.unit, 'stock': item.stock.toString(), 'minimumStock': item.minimumStock.toString(), 'location': item.location ?? '', 'unitPrice': item.unitPrice?.toString() ?? '', 'notes': item.notes ?? ''};
      case _ModuleType.machines: return {'name': item.name, 'serialNumber': item.serialNumber ?? '', 'operatingHours': item.operatingHours.toString(), 'status': item.status, 'notes': item.notes ?? ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _Watermark(),
        FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: _green));
            if (snapshot.hasError) return Center(child: Text('Fehler beim Laden: ${snapshot.error}'));
            final items = snapshot.data ?? [];
            return RefreshIndicator(
              color: _green,
              onRefresh: () async => refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(30, 26, 30, 40),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 54, height: 54, decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(14)), child: Icon(widget.config.icon, color: _green, size: 29)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.config.title, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: _darkGreen)), const SizedBox(height: 3), Text(widget.config.subtitle, style: const TextStyle(color: Colors.black54))])),
                      FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: _green), onPressed: _create, icon: const Icon(Icons.add), label: const Text('Neu')),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(children: [Text('${items.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _darkGreen)), const SizedBox(width: 7), Text(widget.config.title, style: const TextStyle(color: Colors.black54)), const Spacer(), IconButton(onPressed: refresh, tooltip: 'Aktualisieren', icon: const Icon(Icons.refresh))]),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(36),
                        child: Column(children: [Icon(widget.config.icon, size: 52, color: Colors.black26), const SizedBox(height: 12), Text('Noch keine ${widget.config.title} vorhanden.', style: const TextStyle(fontSize: 16)), const SizedBox(height: 14), OutlinedButton.icon(onPressed: _create, icon: const Icon(Icons.add), label: Text('${widget.config.title} anlegen'))]),
                      ),
                    )
                  else
                    ...items.map((item) => _DataCard(config: widget.config, item: item, onEdit: () => _edit(item), onDelete: () => _delete(item))),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _snack(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? Colors.red.shade700 : _green, behavior: SnackBarBehavior.floating));
  }
}

class _DataCard extends StatelessWidget {
  final _ModuleConfig config;
  final dynamic item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DataCard({required this.config, required this.item, required this.onEdit, required this.onDelete});

  String get primary {
    switch (config.type) {
      case _ModuleType.sites: return item.title;
      case _ModuleType.customers: return item.name;
      case _ModuleType.orders: return item.title;
      case _ModuleType.employees: return item.name;
      case _ModuleType.timeEntries: return item.employeeName;
      case _ModuleType.reports: return item.title;
      case _ModuleType.materials: return item.name;
      case _ModuleType.machines: return item.name;
    }
  }

  String get secondary {
    switch (config.type) {
      case _ModuleType.sites: return item.address;
      case _ModuleType.customers: return [item.contact, item.phone, item.address].where((s) => s != null && s.toString().isNotEmpty).join(' • ');
      case _ModuleType.orders: return '${item.status} • ${item.date} • ${item.price.toStringAsFixed(2)} €';
      case _ModuleType.employees: return '${item.role} • ${item.targetHours.toStringAsFixed(1)} h/Woche';
      case _ModuleType.timeEntries: return '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year} • ${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}';
      case _ModuleType.reports: return '${item.date} • ${item.content.length > 80 ? '${item.content.substring(0, 80)}…' : item.content}';
      case _ModuleType.materials: return '${item.stock} ${item.unit} • ${item.category ?? ''}';
      case _ModuleType.machines: return '${item.status} • ${item.operatingHours} h';
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          leading: CircleAvatar(radius: 24, backgroundColor: _lightGreen, child: Icon(config.icon, color: _green)),
          title: Text(primary, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(secondary),
          trailing: Wrap(spacing: 2, children: [IconButton(tooltip: 'Bearbeiten', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: 'Löschen', onPressed: onDelete, icon: const Icon(Icons.delete_outline))]),
          onTap: onEdit,
        ),
      );
}

class _EntryDialog extends StatefulWidget {
  final _ModuleConfig config;
  final Map<String, String>? initial;
  const _EntryDialog({required this.config, this.initial});

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final f in widget.config.fields) {
      _controllers[f.key] = TextEditingController(text: widget.initial?[f.key] ?? f.initial ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String key) async {
    final current = DateTime.tryParse(_controllers[key]!.text) ?? DateTime.now();
    final date = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDate: current);
    if (date != null) _controllers[key]!.text = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(String key) async {
    final parts = _controllers[key]!.text.split(':');
    final time = TimeOfDay(hour: int.tryParse(parts.first) ?? 8, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) _controllers[key]!.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return AlertDialog(
      title: Row(children: [Icon(widget.config.icon, color: _green), const SizedBox(width: 10), Expanded(child: Text(editing ? '${widget.config.title} bearbeiten' : '${widget.config.title} anlegen'))]),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.config.fields.map((f) {
                final isDate = f.key == 'date';
                final isTime = f.key == 'startTime' || f.key == 'endTime';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _controllers[f.key],
                    keyboardType: f.keyboard,
                    minLines: f.multiline ? 4 : 1,
                    maxLines: f.multiline ? 7 : 1,
                    readOnly: isDate || isTime,
                    onTap: isDate ? () => _pickDate(f.key) : isTime ? () => _pickTime(f.key) : null,
                    decoration: InputDecoration(labelText: f.label, border: const OutlineInputBorder(), filled: true, fillColor: Colors.white, suffixIcon: isDate ? const Icon(Icons.calendar_month) : isTime ? const Icon(Icons.access_time) : null),
                    validator: f.required ? (v) => v == null || v.trim().isEmpty ? '${f.label} ist erforderlich.' : null : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: _green), onPressed: () { if (!_formKey.currentState!.validate()) return; Navigator.pop(context, {for (final e in _controllers.entries) e.key: e.value.text.trim()}); }, icon: const Icon(Icons.save), label: const Text('Speichern')),
      ],
    );
  }
}

class CalendarFeatureScreen extends StatefulWidget {
  const CalendarFeatureScreen({super.key});

  @override
  State<CalendarFeatureScreen> createState() => _CalendarFeatureScreenState();
}

class _CalendarFeatureScreenState extends State<CalendarFeatureScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month, 1);
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final offset = (first.weekday + 6) % 7;
    final total = offset + days;
    final cells = ((total + 6) ~/ 7) * 7;
    const names = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    return Stack(
      children: [
        const _Watermark(),
        Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.calendar_month, color: _green, size: 31),
                const SizedBox(width: 10),
                const Expanded(child: Text('Kalender', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: _darkGreen))),
                IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left)),
                Text('${_month.month.toString().padLeft(2, '0')}/${_month.year}', style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: const Icon(Icons.chevron_right)),
              ]),
              const SizedBox(height: 18),
              Expanded(
                child: Card(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.35),
                    itemCount: cells + 7,
                    itemBuilder: (context, i) {
                      if (i < 7) return Center(child: Text(names[i], style: const TextStyle(fontWeight: FontWeight.w700, color: _green)));
                      final dayIndex = i - 7 - offset;
                      if (dayIndex < 0 || dayIndex >= days) return const SizedBox.shrink();
                      final date = DateTime(_month.year, _month.month, dayIndex + 1);
                      final today = DateTime.now();
                      final selected = date.year == today.year && date.month == today.month && date.day == today.day;
                      return Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: selected ? _lightGreen : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? _green : Colors.black12)),
                        child: Align(alignment: Alignment.topLeft, child: Text('${date.day}', style: TextStyle(fontWeight: FontWeight.w700, color: selected ? _darkGreen : Colors.black87))),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _id() => DateTime.now().microsecondsSinceEpoch.toString();

Value<String?> _text(String? value) {
  final v = value?.trim() ?? '';
  return v.isEmpty ? const Value(null) : Value(v);
}

String? _textValue(String? value) {
  final v = value?.trim() ?? '';
  return v.isEmpty ? null : v;
}

Value<int?> _int(String? value) {
  final v = int.tryParse(value?.trim() ?? '');
  return v == null ? const Value(null) : Value(v);
}

double _number(String? value) => double.tryParse((value ?? '0').replaceAll(',', '.')) ?? 0;

double? _nullableNumber(String? value) {
  final v = (value ?? '').trim().replaceAll(',', '.');
  return v.isEmpty ? null : double.tryParse(v);
}

DateTime _parseDate(String value) => DateTime.tryParse(value.trim()) ?? DateTime.now();

DateTime _parseDateTime(String date, String time) {
  final d = _parseDate(date);
  final p = time.split(':');
  return DateTime(d.year, d.month, d.day, int.tryParse(p.first) ?? 8, p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
}
