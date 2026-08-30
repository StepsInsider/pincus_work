import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// Zentrale Provider für die Drift-Datenbank
/// Diese Datei konsolidiert alle Datenbankzugriffe durch Riverpod

/// Provider für die AppDatabase Instanz
/// Singleton-Instanz für alle Features
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
