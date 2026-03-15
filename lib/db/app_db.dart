import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get icon => text().withLength(min: 1, max: 40)(); // identifier to map to IconData
  IntColumn get color => integer()(); // ARGB int
  TextColumn get type => text().withLength(min: 1, max: 16)(); // expense|budget|shopping
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(min: 1, max: 200)();
  IntColumn get categoryId => integer().references(Categories, #id)();
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

@DriftDatabase(tables: [Categories, Expenses, Budgets, ShoppingItems])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  // ---------- Categories (seed + queries)
  Future<int> addCategory({required String name, required String icon, required int color, required String type}) {
    return into(categories).insert(CategoriesCompanion.insert(name: name, icon: icon, color: color, type: type));
  }

  Stream<List<Category>> watchCategories(String type) => (select(categories)..where((t) => t.type.equals(type))).watch();
  Future<List<Category>> listCategories(String type) => (select(categories)..where((t) => t.type.equals(type))).get();

  Future<void> ensureDefaultCategories() async {
    final countExp = await (select(categories)..where((t) => t.type.equals('expense'))).get();
    if (countExp.isNotEmpty) return;

    // Universal defaults (B)
    final defaults = <({String name, String icon, int color, String type})>[
      (name: 'Alimentation', icon: 'restaurant', color: 0xFFD8B45C, type: 'expense'),
      (name: 'Transport', icon: 'directions_car', color: 0xFF4FC3F7, type: 'expense'),
      (name: 'Factures', icon: 'receipt_long', color: 0xFFFFB74D, type: 'expense'),
      (name: 'Santé', icon: 'medical_services', color: 0xFFE57373, type: 'expense'),
      (name: 'Loisirs', icon: 'sports_esports', color: 0xFFBA68C8, type: 'expense'),
      (name: 'Éducation', icon: 'school', color: 0xFF81C784, type: 'expense'),

      (name: 'Budget mensuel', icon: 'pie_chart', color: 0xFFD8B45C, type: 'budget'),
      (name: 'Épargne', icon: 'savings', color: 0xFF81C784, type: 'budget'),

      (name: 'Courses', icon: 'shopping_cart', color: 0xFFD8B45C, type: 'shopping'),
      (name: 'Maison', icon: 'home', color: 0xFF90A4AE, type: 'shopping'),
    ];

    await batch((b) {
      for (final d in defaults) {
        b.insert(categories, CategoriesCompanion.insert(name: d.name, icon: d.icon, color: d.color, type: d.type));
      }
    });
  }

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

  Future<int> addExpense({required double amount, required String note, required int categoryId, DateTime? spentAt}) {
    return into(expenses).insert(ExpensesCompanion.insert(
      amount: amount,
      note: note,
      categoryId: categoryId,
      spentAt: spentAt ?? DateTime.now(),
    ));
  }

  Future<void> deleteExpense(int id) => (delete(expenses)..where((t) => t.id.equals(id))).go();

  // ---------- Budgets
  Stream<List<Budget>> watchBudgets(String month) => (select(budgets)..where((t) => t.month.equals(month))).watch();

  Future<int> addBudget({required double amount, required String month, required int categoryId}) {
    return into(budgets).insert(BudgetsCompanion.insert(
      amount: amount,
      month: month,
      categoryId: categoryId,
    ));
  }

  Future<void> deleteBudget(int id) => (delete(budgets)..where((t) => t.id.equals(id))).go();

  // ---------- Shopping
  Stream<List<ShoppingItem>> watchShopping() => (select(shoppingItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<int> addShoppingItem({required String name, required int categoryId}) {
    return into(shoppingItems).insert(ShoppingItemsCompanion.insert(
      name: name,
      categoryId: categoryId,
    ));
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
        if (from == 1) {
          await m.createTable(categories);
          // This is a breaking schema change. For v1->v2 we reset local DB.
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
