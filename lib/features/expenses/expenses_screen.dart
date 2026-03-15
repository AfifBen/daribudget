import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../db/app_db.dart';
import '../charts/pie_chart.dart';
import 'add_expense_sheet.dart';

enum ExpenseRange { day, week, month, year }

enum OpsTab { expenses, income }

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpenseRange range = ExpenseRange.month;
  OpsTab opsTab = OpsTab.expenses;
  int? categoryFilterId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    final appState = context.watch<AppState>();

    final (start, end) = _rangeToDates(range, appState.weekStart);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Opérations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                ),
                Text(_rangeLabel(range), style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),

            // Tabs: Dépenses / Revenus (Revenus à venir)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => setState(() => opsTab = OpsTab.expenses),
                        child: const Text('Dépenses'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: null,
                        child: const Text('Revenus (à venir)'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Range selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<ExpenseRange>(
                    segments: const [
                      ButtonSegment(value: ExpenseRange.day, label: Text('Jour')),
                      ButtonSegment(value: ExpenseRange.week, label: Text('Semaine')),
                      ButtonSegment(value: ExpenseRange.month, label: Text('Mois')),
                      ButtonSegment(value: ExpenseRange.year, label: Text('Année')),
                    ],
                    selected: {range},
                    onSelectionChanged: (s) => setState(() => range = s.first),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter (pro)
            Card(
              child: ListTile(
                leading: const Icon(Icons.filter_alt_outlined),
                title: FutureBuilder<List<Category>>(
                  future: db.listCategories(),
                  builder: (context, snap) {
                    final cats = snap.data ?? const <Category>[];
                    if (cats.isEmpty) return const Text('Toutes les catégories');
                    if (categoryFilterId == null) return const Text('Toutes les catégories');
                    final found = cats.where((c) => c.id == categoryFilterId).toList();
                    return Text(found.isEmpty ? 'Toutes les catégories' : found.first.name);
                  },
                ),
                subtitle: const Text('Filtrer les dépenses'),
                trailing: const Icon(Icons.expand_more),
                onTap: () => _pickCategoryFilter(context, db),
              ),
            ),

            const SizedBox(height: 12),

            // Pie: subcategories (for this range)
            FutureBuilder<List<SubcategoryTotal>>(
              future: db.expensesBySubcategoryForMonth(_currentMonthKey(), categoryId: categoryFilterId),
              builder: (context, snap) {
                final rows = (snap.data ?? const <SubcategoryTotal>[]).where((r) => r.total > 0).toList();
                if (rows.isEmpty) return const SizedBox.shrink();

                final top = rows.take(6).toList();
                final rest = rows.skip(6).fold<double>(0, (s, r) => s + r.total);

                final slices = <PieSlice>[
                  for (final r in top) PieSlice(value: r.total, color: Color(r.color), label: r.name),
                  if (rest > 0) const PieSlice(value: 0, color: Colors.white24, label: 'Autres'),
                ];
                if (rest > 0) slices[slices.length - 1] = PieSlice(value: rest, color: Colors.white24, label: 'Autres');

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Répartition par sous‑catégorie', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SimplePieChart(slices: slices, size: 130),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final s in slices.take(7))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: s.color,
                                              borderRadius: BorderRadius.circular(99),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              s.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Grouped list by date
            StreamBuilder<List<Expense>>(
              stream: db.watchExpensesBetween(start, end),
              builder: (context, snap) {
                final all = snap.data ?? const <Expense>[];
                if (all.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucune dépense pour cette période.'),
                    ),
                  );
                }

                return FutureBuilder<List<Subcategory>>(
                  future: db.select(db.subcategories).get(),
                  builder: (context, subSnap) {
                    final subs = subSnap.data ?? const <Subcategory>[];
                    final subToCat = {for (final s in subs) s.id: s.categoryId};
                    final subToName = {for (final s in subs) s.id: s.name};

                    final filtered = categoryFilterId == null
                        ? all
                        : all.where((e) => subToCat[e.subcategoryId] == categoryFilterId).toList();

                    // group by YYYY-MM-DD
                    final groups = <String, List<Expense>>{};
                    for (final e in filtered) {
                      final key = _fmtDate(e.spentAt);
                      (groups[key] ??= []).add(e);
                    }
                    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final k in keys) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white70)),
                          ),
                          for (final e in groups[k]!)
                            Card(
                              child: ListTile(
                                title: Text(subToName[e.subcategoryId] ?? e.note, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: e.note.trim().isEmpty ? null : Text(e.note, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: Text('${e.amount.toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.w900)),
                              ),
                            ),
                        ]
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),

        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: opsTab == OpsTab.expenses
                ? () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const AddExpenseSheet(),
                    )
                : null,
            child: const Icon(Icons.add),
          ),
        )
      ],
    );
  }

  Future<void> _pickCategoryFilter(BuildContext context, AppDb db) async {
    final cats = await db.listCategories();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Filtrer par catégorie', style: TextStyle(fontWeight: FontWeight.w900)),
                trailing: TextButton(
                  onPressed: () {
                    setState(() => categoryFilterId = null);
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              for (final c in cats)
                ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(c.name),
                  onTap: () {
                    setState(() => categoryFilterId = c.id);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String _currentMonthKey() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  return '${now.year}-$m';
}

String _rangeLabel(ExpenseRange r) {
  switch (r) {
    case ExpenseRange.day:
      return 'Aujourd\'hui';
    case ExpenseRange.week:
      return 'Cette semaine';
    case ExpenseRange.month:
      return 'Ce mois';
    case ExpenseRange.year:
      return 'Cette année';
  }
}

(DateTime, DateTime) _rangeToDates(ExpenseRange r, WeekStart weekStart) {
  final now = DateTime.now();
  DateTime start;
  DateTime end;

  switch (r) {
    case ExpenseRange.day:
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
      return (start, end);
    case ExpenseRange.week:
      // week start config
      final dow = now.weekday % 7; // Sunday=0
      final currentSunday = DateTime(now.year, now.month, now.day).subtract(Duration(days: dow));
      final currentMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      start = weekStart == WeekStart.sunday ? currentSunday : currentMonday;
      end = start.add(const Duration(days: 7));
      return (start, end);
    case ExpenseRange.month:
      start = DateTime(now.year, now.month, 1);
      end = (now.month == 12) ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
      return (start, end);
    case ExpenseRange.year:
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year + 1, 1, 1);
      return (start, end);
  }
}
