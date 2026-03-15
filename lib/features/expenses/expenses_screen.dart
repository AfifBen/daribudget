import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../charts/pie_chart.dart';
import 'add_expense_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  int? categoryFilterId; // null => all

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    final month = _currentMonthKey();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Dépenses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                ),
                Text(month, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),

            // Filter (pro): one button
            Card(
              child: ListTile(
                leading: const Icon(Icons.filter_alt_outlined),
                title: FutureBuilder<List<Category>>(
                  future: db.listCategories(),
                  builder: (context, snap) {
                    final cats = snap.data ?? const <Category>[];
                    final name = categoryFilterId == null
                        ? 'Toutes les catégories'
                        : (cats.firstWhere((c) => c.id == categoryFilterId, orElse: () => cats.first).name);
                    return Text(name);
                  },
                ),
                subtitle: const Text('Filtrer les dépenses'),
                trailing: const Icon(Icons.expand_more),
                onTap: () => _pickCategoryFilter(context, db),
              ),
            ),

            const SizedBox(height: 12),

            // Pie: subcategories
            FutureBuilder<List<SubcategoryTotal>>(
              future: db.expensesBySubcategoryForMonth(month, categoryId: categoryFilterId),
              builder: (context, snap) {
                final rows = (snap.data ?? const <SubcategoryTotal>[]).where((r) => r.total > 0).toList();
                if (rows.isEmpty) return const SizedBox.shrink();

                final top = rows.take(6).toList();
                final rest = rows.skip(6).fold<double>(0, (s, r) => s + r.total);

                final slices = <PieSlice>[
                  for (final r in top) PieSlice(value: r.total, color: Color(r.color), label: r.name),
                  if (rest > 0) const PieSlice(value: 0, color: Colors.white24, label: 'Autres'),
                ];
                if (rest > 0) {
                  slices[slices.length - 1] = PieSlice(value: rest, color: Colors.white24, label: 'Autres');
                }

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

            // List
            StreamBuilder<List<Expense>>(
              stream: db.watchExpensesForMonth(month),
              builder: (context, snap) {
                final items = snap.data ?? const <Expense>[];
                if (items.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucune dépense ce mois‑ci.'),
                    ),
                  );
                }

                // if filter set, keep only those matching category via subcategory lookup
                return FutureBuilder<List<Subcategory>>(
                  future: db.select(db.subcategories).get(),
                  builder: (context, subSnap) {
                    final subs = subSnap.data ?? const <Subcategory>[];
                    final subToCat = {for (final s in subs) s.id: s.categoryId};

                    final filtered = categoryFilterId == null
                        ? items
                        : items.where((e) => subToCat[e.subcategoryId] == categoryFilterId).toList();

                    return FutureBuilder<List<Category>>(
                      future: db.listCategories(),
                      builder: (context, catSnap) {
                        final cats = catSnap.data ?? const <Category>[];
                        final catMap = {for (final c in cats) c.id: c};

                        return Column(
                          children: [
                            for (final e in filtered)
                              Builder(builder: (context) {
                                final sub = subs.firstWhere((s) => s.id == e.subcategoryId, orElse: () => subs.first);
                                final cat = catMap[sub.categoryId];
                                final title = cat == null ? sub.name : '${cat.name} / ${sub.name}';
                                final subtitle = e.note.trim().isEmpty ? _fmtDate(e.spentAt) : '${e.note} • ${_fmtDate(e.spentAt)}';

                                return Card(
                                  child: ListTile(
                                    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    subtitle: Text(
                                      subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white60),
                                    ),
                                    trailing: Text('${e.amount.toStringAsFixed(0)} DA',
                                        style: const TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                );
                              }),
                          ],
                        );
                      },
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
          child: FloatingActionButton.extended(
            onPressed: () => showDialog(context: context, builder: (_) => const AddExpenseDialog()),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
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
