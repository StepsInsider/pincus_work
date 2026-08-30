import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Sites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get address => text()();
  TextColumn get customerId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class TimeEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siteId => integer().references(Sites, #id)();
  TextColumn get employeeName => text()();
  DateTimeColumn get date => dateTime()(); // Tag der Leistung
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  RealColumn get breakMinutes => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SitePhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siteId => integer().references(Sites, #id)();
  TextColumn get category => text()(); // Vorher, Arbeitsfortschritt, Nachher, Mangel, Material, Maschine, Abnahme
  TextColumn get filePath => text()(); // Lokaler Speicherpfad auf dem Gerät
  TextColumn get notes => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Sites, TimeEntries, SitePhotos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'pincus_database.db'));
      return NativeDatabase(file);
    });
  }
}
