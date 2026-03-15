import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

// v3: Categories + Subcategories (customizable)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get icon => text().withLength(min: 1, max: 40)();
  IntColumn get color => integer()(); // ARGB int
}

class Subcategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get icon => text().withLength(min: 1, max: 40)();
  IntColumn get color => integer()(); // ARGB int
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(min: 1, max: 200)();
  IntColumn get subcategoryId => integer().references(Subcategories, #id)();
  DateTimeColumn get spentAt => dateTime()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get month => text().withLength(min: 7, max: 7)(); // YYYY-MM
}

class ShoppingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Categories, Subcategories, Expenses, Budgets, ShoppingItems])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  // ---------- Defaults (seed)
  Future<void> ensureDefaultCategories() async {
    final existing = await select(categories).get();
    if (existing.isNotEmpty) return;

    Future<int> addCat(String name, String icon, int color) {
      return into(categories).insert(CategoriesCompanion.insert(name: name, icon: icon, color: color));
    }

    // Default universal categories (editable later)
    final foodId = await addCat('Alimentation', 'restaurant', 0xFFD8B45C);
    final transportId = await addCat('Transport', 'directions_car', 0xFF4FC3F7);
    final billsId = await addCat('Factures', 'receipt_long', 0xFFFFB74D);
    final healthId = await addCat('Santé', 'medical_services', 0xFFE57373);
    final leisureId = await addCat('Loisirs', 'sports_esports', 0xFFBA68C8);
    final eduId = await addCat('Éducation', 'school', 0xFF81C784);

    // Budget categories
    await addCat('Budget mensuel', 'pie_chart', 0xFFD8B45C);
    await addCat('Épargne', 'savings', 0xFF81C784);

    // Shopping categories
    await addCat('Courses', 'shopping_cart', 0xFFD8B45C);
    await addCat('Maison', 'home', 0xFF90A4AE);

    Future<void> addSub(int catId, String name, String icon, int color) async {
      await into(subcategories).insert(SubcategoriesCompanion.insert(
        categoryId: catId,
        name: name,
        icon: icon,
        color: color,
      ));
    }

    // Alimentation
    for (final name in ['Viandes', 'Légumes', 'Fruits', 'Laitages', 'Boulangerie', 'Boissons', 'Épices']) {
      await addSub(foodId, name, 'restaurant', 0xFFD8B45C);
    }

    // Transport
    for (final name in ['Carburant', 'Taxi', 'Maintenance']) {
      await addSub(transportId, name, 'directions_car', 0xFF4FC3F7);
    }

    // Factures
    for (final name in ['Électricité', 'Eau', 'Internet', 'Téléphone']) {
      await addSub(billsId, name, 'receipt_long', 0xFFFFB74D);
    }

    // Santé
    for (final name in ['Médecin', 'Pharmacie']) {
      await addSub(healthId, name, 'medical_services', 0xFFE57373);
    }

    // Loisirs
    for (final name in ['Jeux', 'Sorties']) {
      await addSub(leisureId, name, 'sports_esports', 0xFFBA68C8);
    }

    // Éducation
    for (final name in ['Frais scolaires', 'Livres']) {
      await addSub(eduId, name, 'school', 0xFF81C784);
    }
  }

  // ---------- Categories queries
  Stream<List<Category>> watchCategories() => (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  Future<List<Category>> listCategories() => (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<Subcategory>> watchSubcategories(int categoryId) =>
      (select(subcategories)..where((t) => t.categoryId.equals(categoryId))..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  Future<List<Subcategory>> listSubcategories(int categoryId) =>
      (select(subcategories)..where((t) => t.categoryId.equals(categoryId))..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  // ---------- Expenses
  Stream<List<Expense>> watchExpenses() => (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.spentAt)])).watch();

  Stream<List<Expense>> watchExpensesForMonth(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final start = DateTime(year, month, 1);
    final end = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);

    return (select(expenses)
          ..where((t) => t.spentAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.spentAt)]))
        .watch();
  }

  Future<int> addExpense({required double amount, required String note, required int subcategoryId, DateTime? spentAt}) {
    return into(expenses).insert(ExpensesCompanion.insert(
      amount: amount,
      note: note,
      subcategoryId: subcategoryId,
      spentAt: spentAt ?? DateTime.now(),
    ));
  }

  Future<void> deleteExpense(int id) => (delete(expenses)..where((t) => t.id.equals(id))).go();

  // ---------- Budgets
  Stream<List<Budget>> watchBudgets(String month) => (select(budgets)..where((t) => t.month.equals(month))).watch();
  Future<int> addBudget({required double amount, required String month, required int categoryId}) {
    return into(budgets).insert(BudgetsCompanion.insert(amount: amount, month: month, categoryId: categoryId));
  }
  Future<void> deleteBudget(int id) => (delete(budgets)..where((t) => t.id.equals(id))).go();

  // ---------- Shopping
  Stream<List<ShoppingItem>> watchShopping() => (select(shoppingItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Future<int> addShoppingItem({required String name, required int categoryId}) {
    return into(shoppingItems).insert(ShoppingItemsCompanion.insert(name: name, categoryId: categoryId));
  }
  Future<void> toggleShoppingDone(int id, bool done) {
    return (update(shoppingItems)..where((t) => t.id.equals(id))).write(ShoppingItemsCompanion(done: Value(done)));
  }
  Future<void> deleteShoppingItem(int id) => (delete(shoppingItems)..where((t) => t.id.equals(id))).go();

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await ensureDefaultCategories();
      },
      onUpgrade: (m, from, to) async {
        if (from <= 2) {
          // Breaking change: reset local data
          await m.createTable(categories);
          await m.createTable(subcategories);
          await m.deleteTable(expenses.actualTableName);
          await m.deleteTable(budgets.actualTableName);
          await m.deleteTable(shoppingItems.actualTableName);
          await m.createTable(expenses);
          await m.createTable(budgets);
          await m.createTable(shoppingItems);
          await ensureDefaultCategories();
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'daribudget.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
