import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppRepository {
  static final AppRepository _instance = AppRepository._internal();
  factory AppRepository() => _instance;
  AppRepository._internal();

  // In-Memory-Datenlisten als Single Source of Truth
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> sites = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> timeEntries = [];
  List<Map<String, dynamic>> materials = [];
  List<Map<String, dynamic>> machines = [];
  List<Map<String, dynamic>> defects = [];
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> employees = [
    {"id": "1", "name": "René Pincus", "role": "Chef", "color": "0xFF2E7D32"},
    {"id": "2", "name": "Max Mustermann", "role": "Geselle", "color": "0xFF1976D2"},
    {"id": "3", "name": "Stefan Baumpfleger", "role": "Baumpfleger", "color": "0xFFF57C00"},
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Testdaten laden falls leer
    if (!prefs.containsKey('initialized')) {
      _loadInitialData();
      await saveData();
      await prefs.setBool('initialized', true);
    } else {
      await loadData();
    }
  }

  void _loadInitialData() {
    customers = [
      {"id": "c1", "name": "Stadt Dortmund", "contact": "Herr Meyer", "phone": "0231-123456", "address": "Südstr. 14, Dortmund"},
      {"id": "c2", "name": "Familie Meier", "contact": "Anna Meier", "phone": "0231-987654", "address": "Aplerbecker Mark 5, Dortmund"},
    ];
    sites = [
      {"id": "s1", "customerId": "c1", "title": "Baumfällung Aplerbeck", "address": "Aplerbecker Str. 10", "status": "In Arbeit", "value": 1200.0},
      {"id": "s2", "customerId": "c2", "title": "Gartenneugestaltung", "address": "Aplerbecker Mark 5", "status": "Geplant", "value": 2400.0},
    ];
    orders = [
      {"id": "o1", "siteId": "s1", "title": "Gefahrenbaum-Fällung inkl. Entsorgung", "status": "In Arbeit", "date": "2026-08-27", "price": 1200.0},
    ];
    timeEntries = [
      {"id": "t1", "employee": "René Pincus", "site": "Baumfällung Aplerbeck", "hours": "4.5", "date": "2026-08-27", "note": "Fällung durchgeführt"},
    ];
    materials = [
      {"id": "m1", "site": "Baumfällung Aplerbeck", "item": "Kettensägenöl & Benzin", "cost": "45.00 €"},
    ];
    defects = [
      {"id": "d1", "site": "Baumfällung Aplerbeck", "description": "Wurzelstock muss nachgefräst werden", "status": "Neu", "priority": "Hoch"},
    ];
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customers', jsonEncode(customers));
    await prefs.setString('sites', jsonEncode(sites));
    await prefs.setString('orders', jsonEncode(orders));
    await prefs.setString('timeEntries', jsonEncode(timeEntries));
    await prefs.setString('materials', jsonEncode(materials));
    await prefs.setString('machines', jsonEncode(machines));
    await prefs.setString('defects', jsonEncode(defects));
    await prefs.setString('reports', jsonEncode(reports));
    await prefs.setString('employees', jsonEncode(employees));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    customers = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('customers') ?? '[]'));
    sites = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('sites') ?? '[]'));
    orders = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('orders') ?? '[]'));
    timeEntries = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('timeEntries') ?? '[]'));
    materials = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('materials') ?? '[]'));
    machines = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('machines') ?? '[]'));
    defects = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('defects') ?? '[]'));
    reports = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('reports') ?? '[]'));
    employees = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('employees') ?? '[]'));
  }
}
