import 'package:drift/drift.dart';
import 'package:drift/web.dart';

DatabaseConnection openConnection() {
  return DatabaseConnection(
    WebDatabase(
      'pincus_database',
    ),
  );
}
