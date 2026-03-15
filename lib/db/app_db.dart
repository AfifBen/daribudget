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
class CategoryTotal {
  final int categoryId;
  final String name;
  final String icon;
  final int color;
  final double total;

  const CategoryTotal({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    required this.total,
  });
}

class SubcategoryTotal {
  final int subcategoryId;
  final String name;
  final String icon;
  final int color;
  final int categoryId;
  final String categoryName;
  final double total;

  const SubcategoryTotal({
    required this.subcategoryId,
    required this.name,
    required this.icon,
    required this.color,
    required this.categoryId,
    required this.categoryName,
    required this.total,
  });
}

class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  // ---------- Category CRUD
  Future<int> createCategory({required String name, required String icon, required int color}) {
    return into(categories).insert(CategoriesCompanion.insert(name: name, icon: icon, color: color));
  }

  Future<void> updateCategory(int id, {String? name, String? icon, int? color}) {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: name == null ? const Value.absent() : Value(name),
        icon: icon == null ? const Value.absent() : Value(icon),
        color: color == null ? const Value.absent() : Value(color),
      ),
    );
  }

  Future<bool> deleteCategory(int id) async {
    final subs = await (select(subcategories)..where((t) => t.categoryId.equals(id))).get();
    // If any subcategory is referenced by an expense, block delete.
    for (final s in subs) {
      final count = await (select(expenses)..where((t) => t.subcategoryId.equals(s.id))).get();
      if (count.isNotEmpty) return false;
    }
    await (delete(subcategories)..where((t) => t.categoryId.equals(id))).go();
    await (delete(categories)..where((t) => t.id.equals(id))).go();
    return true;
  }

  // ---------- Subcategory CRUD
  Future<int> createSubcategory({required int categoryId, required String name, required String icon, required int color}) {
    return into(subcategories).insert(SubcategoriesCompanion.insert(
      categoryId: categoryId,
      name: name,
      icon: icon,
      color: color,
    ));
  }

  Future<void> updateSubcategory(int id, {String? name, String? icon, int? color}) {
    return (update(subcategories)..where((t) => t.id.equals(id))).write(
      SubcategoriesCompanion(
        name: name == null ? const Value.absent() : Value(name),
        icon: icon == null ? const Value.absent() : Value(icon),
        color: color == null ? const Value.absent() : Value(color),
      ),
    );
  }

  Future<bool> deleteSubcategory(int id) async {
    final used = await (select(expenses)..where((t) => t.subcategoryId.equals(id))).get();
    if (used.isNotEmpty) return false;
    await (delete(subcategories)..where((t) => t.id.equals(id))).go();
    return true;
  }

  @override
  int get schemaVersion => 3;

  // ---------- Defaults (seed)
  Future<void> ensureDefaultCategories() async {
    final existingCats = await select(categories).get();
    final existingSubs = await select(subcategories).get();

    Future<int> addCat(String name, String icon, int color) {
      return into(categories).insert(CategoriesCompanion.insert(name: name, icon: icon, color: color));
    }

    Future<void> addSub(int catId, String name, String icon, int color) async {
      await into(subcategories).insert(SubcategoriesCompanion.insert(
        categoryId: catId,
        name: name,
        icon: icon,
        color: color,
      ));
    }

    // If nothing exists, seed everything
    if (existingCats.isEmpty) {
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

      // Subcategories (mandatory for expenses)
      for (final name in ['Viandes', 'Légumes', 'Fruits', 'Laitages', 'Boulangerie', 'Boissons', 'Épices']) {
        await addSub(foodId, name, 'restaurant', 0xFFD8B45C);
      }
      for (final name in ['Carburant', 'Taxi', 'Maintenance']) {
        await addSub(transportId, name, 'directions_car', 0xFF4FC3F7);
      }
      for (final name in ['Électricité', 'Eau', 'Internet', 'Téléphone']) {
        await addSub(billsId, name, 'receipt_long', 0xFFFFB74D);
      }
      for (final name in ['Médecin', 'Pharmacie']) {
        await addSub(healthId, name, 'medical_services', 0xFFE57373);
      }
      for (final name in ['Jeux', 'Sorties']) {
        await addSub(leisureId, name, 'sports_esports', 0xFFBA68C8);
      }
      for (final name in ['Frais scolaires', 'Livres']) {
        await addSub(eduId, name, 'school', 0xFF81C784);
      }
      return;
    }

    // If categories exist but subcategories are missing (common after upgrades), seed subcategories only
    if (existingSubs.isEmpty) {
      final byName = {for (final c in existingCats) c.name: c.id};
      final foodId = byName['Alimentation'];
      final transportId = byName['Transport'];
      final billsId = byName['Factures'];
      final healthId = byName['Santé'];
      final leisureId = byName['Loisirs'];
      final eduId = byName['Éducation'];

      if (foodId != null) {
        for (final name in ['Viandes', 'Légumes', 'Fruits', 'Laitages', 'Boulangerie', 'Boissons', 'Épices']) {
          await addSub(foodId, name, 'restaurant', 0xFFD8B45C);
        }
      }
      if (transportId != null) {
        for (final name in ['Carburant', 'Taxi', 'Maintenance']) {
          await addSub(transportId, name, 'directions_car', 0xFF4FC3F7);
        }
      }
      if (billsId != null) {
        for (final name in ['Électricité', 'Eau', 'Internet', 'Téléphone']) {
          await addSub(billsId, name, 'receipt_long', 0xFFFFB74D);
        }
      }
      if (healthId != null) {
        for (final name in ['Médecin', 'Pharmacie']) {
          await addSub(healthId, name, 'medical_services', 0xFFE57373);
        }
      }
      if (leisureId != null) {
        for (final name in ['Jeux', 'Sorties']) {
          await addSub(leisureId, name, 'sports_esports', 0xFFBA68C8);
        }
      }
      if (eduId != null) {
        for (final name in ['Frais scolaires', 'Livres']) {
          await addSub(eduId, name, 'school', 0xFF81C784);
        }
      }
    }
  }

  // ---------- Categories queries
  Stream<List<Category>> watchCategories() => (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  Future<List<Category>> listCategories() => (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  /// Only categories that have at least one subcategory (required for expenses)
  Future<List<Category>> listExpenseCategories() {
    final c = categories.actualTableName;
    final s = subcategories.actualTableName;
    return customSelect(
      'SELECT DISTINCT $c.* FROM $c INNER JOIN $s ON $s.category_id = $c.id ORDER BY $c.name',
      readsFrom: {categories, subcategories},
    ).map((row) => categories.map(row.data)).get();
  }

  Stream<List<Subcategory>> watchSubcategories(int categoryId) =>
      (select(subcategories)..where((t) => t.categoryId.equals(categoryId))..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  Future<List<Subcategory>> listSubcategories(int categoryId) =>
      (select(subcategories)..where((t) => t.categoryId.equals(categoryId))..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  // ---------- Expenses
  Stream<List<Expense>> watchExpenses() => (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.spentAt)])).watch();

  Stream<List<Expense>> watchExpensesForMonth(String monthKey) {
    final range = monthRange(monthKey);
    return (select(expenses)
          ..where((t) => t.spentAt.isBetweenValues(range.$1, range.$2))
          ..orderBy([(t) => OrderingTerm.desc(t.spentAt)]))
        .watch();
  }

  (DateTime, DateTime) monthRange(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final start = DateTime(year, month, 1);
    final end = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return (start, end);
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

  /// Aggregation: total expenses per category for a month
  Future<List<CategoryTotal>> expensesByCategoryForMonth(String monthKey) async {
    final range = monthRange(monthKey);
    final startIso = range.$1.toIso8601String();
    final endIso = range.$2.toIso8601String();

    final c = categories.actualTableName;
    final s = subcategories.actualTableName;
    final e = expenses.actualTableName;

    final rows = await customSelect(
      'SELECT $c.id AS category_id, $c.name AS category_name, $c.icon AS category_icon, $c.color AS category_color, '
      'SUM($e.amount) AS total_amount '
      'FROM $e '
      'JOIN $s ON $s.id = $e.subcategory_id '
      'JOIN $c ON $c.id = $s.category_id '
      'WHERE $e.spent_at >= ? AND $e.spent_at < ? '
      'GROUP BY $c.id, $c.name, $c.icon, $c.color '
      'ORDER BY total_amount DESC',
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
      readsFrom: {categories, subcategories, expenses},
    ).get();

    return rows.map((r) {
      final d = r.data;
      return CategoryTotal(
        categoryId: d['category_id'] as int,
        name: d['category_name'] as String,
        icon: d['category_icon'] as String,
        color: d['category_color'] as int,
        total: (d['total_amount'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  /// Aggregation: total expenses per subcategory for a month (optionally for one category)
  Future<List<SubcategoryTotal>> expensesBySubcategoryForMonth(String monthKey, {int? categoryId}) async {
    final range = monthRange(monthKey);
    final startIso = range.$1.toIso8601String();
    final endIso = range.$2.toIso8601String();

    final c = categories.actualTableName;
    final s = subcategories.actualTableName;
    final e = expenses.actualTableName;

    final whereCat = categoryId == null ? '' : ' AND $c.id = ? ';
    final vars = <Variable>[Variable.withString(startIso), Variable.withString(endIso)];
    if (categoryId != null) vars.add(Variable.withInt(categoryId));

    final rows = await customSelect(
      'SELECT $s.id AS sub_id, $s.name AS sub_name, $s.icon AS sub_icon, $s.color AS sub_color, '
      '$c.id AS category_id, $c.name AS category_name, '
      'SUM($e.amount) AS total_amount '
      'FROM $e '
      'JOIN $s ON $s.id = $e.subcategory_id '
      'JOIN $c ON $c.id = $s.category_id '
      'WHERE $e.spent_at >= ? AND $e.spent_at < ? '
      '$whereCat '
      'GROUP BY $s.id, $s.name, $s.icon, $s.color, $c.id, $c.name '
      'ORDER BY total_amount DESC',
      variables: vars,
      readsFrom: {categories, subcategories, expenses},
    ).get();

    return rows.map((r) {
      final d = r.data;
      return SubcategoryTotal(
        subcategoryId: d['sub_id'] as int,
        name: d['sub_name'] as String,
        icon: d['sub_icon'] as String,
        color: d['sub_color'] as int,
        categoryId: d['category_id'] as int,
        categoryName: d['category_name'] as String,
        total: (d['total_amount'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

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
