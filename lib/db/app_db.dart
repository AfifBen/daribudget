import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(min: 1, max: 200)();
  TextColumn get category => text().withLength(min: 1, max: 40).withDefault(const Constant('Général'))();
  DateTimeColumn get spentAt => dateTime()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get category => text().withLength(min: 1, max: 40).withDefault(const Constant('Général'))();
  TextColumn get month => text().withLength(min: 7, max: 7)(); // YYYY-MM
}

class ShoppingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get category => text().withLength(min: 1, max: 40).withDefault(const Constant('Général'))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Expenses, Budgets, ShoppingItems])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Expenses
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
  Future<int> addExpense({required double amount, required String note, String category = 'Général', DateTime? spentAt}) {
    return into(expenses).insert(ExpensesCompanion.insert(
      amount: amount,
      note: note,
      category: Value(category),
      spentAt: spentAt ?? DateTime.now(),
    ));
  }
  Future<void> deleteExpense(int id) => (delete(expenses)..where((t) => t.id.equals(id))).go();

  // Budgets
  Stream<List<Budget>> watchBudgets(String month) => (select(budgets)..where((t) => t.month.equals(month))).watch();
  Future<int> addBudget({required double amount, required String month, String category = 'Général'}) {
    return into(budgets).insert(BudgetsCompanion.insert(
      amount: amount,
      month: month,
      category: Value(category),
    ));
  }
  Future<void> deleteBudget(int id) => (delete(budgets)..where((t) => t.id.equals(id))).go();

  // Shopping
  Stream<List<ShoppingItem>> watchShopping() => (select(shoppingItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Future<int> addShoppingItem({required String name, String category = 'Général'}) {
    return into(shoppingItems).insert(ShoppingItemsCompanion.insert(
      name: name,
      category: Value(category),
    ));
  }
  Future<void> toggleShoppingDone(int id, bool done) {
    return (update(shoppingItems)..where((t) => t.id.equals(id))).write(ShoppingItemsCompanion(done: Value(done)));
  }
  Future<void> deleteShoppingItem(int id) => (delete(shoppingItems)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'daribudget.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
