import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_providers.dart';

class MaterialRepository {
  final AppDatabase _db;
  MaterialRepository(this._db);

  /// Alle Materialien anschauen
  Stream<List<Material>> watchAllMaterials() {
    return (_db.select(_db.materials)
          ..orderBy([(m) => OrderingTerm.asc(m.name)]))
        .watch();
  }

  /// Materialien mit niedrigem Bestand (unter Mindestbestand)
  Stream<List<Material>> watchLowStockMaterials() {
    return (_db.select(_db.materials)
          ..where((m) => m.stock.isSmallerThanValue(m.minimumStock))
          ..orderBy([(m) => OrderingTerm.asc(m.name)]))
        .watch();
  }

  /// Materialien nach Kategorie anschauen
  Stream<List<Material>> watchMaterialsByCategory(String category) {
    return (_db.select(_db.materials)
          ..where((m) => m.category.equals(category))
          ..orderBy([(m) => OrderingTerm.asc(m.name)]))
        .watch();
  }

  /// Alle Material-Kategorien abrufen
  Future<List<String?>> getMaterialCategories() async {
    final query = _db.select(_db.materials);
    final materials = await query.get();
    return materials.map((m) => m.category).toList()..removeWhere((c) => c == null);
  }

  /// Neues Material hinzufügen
  Future<int> addMaterial({
    required String name,
    String? articleNumber,
    double stock = 0.0,
    String unit = 'Stk',
    double minimumStock = 0.0,
    String? location,
    String? category,
    String? notes,
  }) {
    return _db.into(_db.materials).insert(MaterialsCompanion.insert(
      name: name,
      articleNumber: Value(articleNumber),
      stock: Value(stock),
      unit: Value(unit),
      minimumStock: Value(minimumStock),
      location: Value(location),
      category: Value(category),
      notes: Value(notes),
    ));
  }

  /// Bestand aktualisieren (Absolute Menge)
  Future<void> updateStock(int materialId, double newStock) async {
    await (_db.update(_db.materials)..where((m) => m.id.equals(materialId)))
        .write(MaterialsCompanion(
      stock: Value(newStock),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Bestand ändern (Relative Menge: positiv = hinzufügen, negativ = entnehmen)
  Future<void> adjustStock(int materialId, double adjustment) async {
    final material = await _db.select(_db.materials)
        .where((m) => m.id.equals(materialId))
        .getSingleOrNull();
    
    if (material != null) {
      final newStock = material.stock + adjustment;
      await updateStock(materialId, newStock > 0 ? newStock : 0);
    }
  }

  /// Material-Informationen aktualisieren
  Future<void> updateMaterial(
    int materialId, {
    String? name,
    String? articleNumber,
    String? unit,
    double? minimumStock,
    String? location,
    String? category,
    String? notes,
  }) async {
    await (_db.update(_db.materials)..where((m) => m.id.equals(materialId)))
        .write(MaterialsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      articleNumber:
          articleNumber != null ? Value(articleNumber) : const Value.absent(),
      unit: unit != null ? Value(unit) : const Value.absent(),
      minimumStock:
          minimumStock != null ? Value(minimumStock) : const Value.absent(),
      location: location != null ? Value(location) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Material löschen
  Future<void> deleteMaterial(int materialId) async {
    await (_db.delete(_db.materials)..where((m) => m.id.equals(materialId)))
        .go();
  }

  /// Bestandswert berechnen (Menge × Einheit-Faktor für m³, kg, etc.)
  double calculateInventoryValue(Material material) {
    return material.stock;
  }

  /// Prüfen ob Material unter Mindestbestand ist
  bool isLowStock(Material material) {
    return material.stock < material.minimumStock;
  }
}

// Riverpod Provider Definitionen
final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(ref.watch(databaseProvider));
});

final materialsStreamProvider = StreamProvider<List<Material>>((ref) {
  return ref.watch(materialRepositoryProvider).watchAllMaterials();
});

final lowStockMaterialsProvider = StreamProvider<List<Material>>((ref) {
  return ref.watch(materialRepositoryProvider).watchLowStockMaterials();
});

final materialsByCategoryProvider =
    StreamProvider.family<List<Material>, String>((ref, category) {
  return ref.watch(materialRepositoryProvider)
      .watchMaterialsByCategory(category);
});

final materialCategoriesProvider = FutureProvider<List<String?>>((ref) async {
  return ref.watch(materialRepositoryProvider).getMaterialCategories();
});
