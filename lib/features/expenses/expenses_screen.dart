import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../categories/category_ui.dart';
import 'add_expense_dialog.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    return _ExpensesWithFilter(db: db);
  }
}

class _ExpensesWithFilter extends StatefulWidget {
  final AppDb db;
  const _ExpensesWithFilter({required this.db});

  @override
  State<_ExpensesWithFilter> createState() => _ExpensesWithFilterState();
}

class _ExpensesWithFilterState extends State<_ExpensesWithFilter> {
  int? selectedCategoryId; // null = all

  @override
  Widget build(BuildContext context) {
    final db = widget.db;

    return Stack(
      children: [
        StreamBuilder<List<Category>>(
          stream: db.watchCategories('expense'),
          builder: (context, catSnap) {
            final cats = catSnap.data ?? const <Category>[];
            final map = {for (final c in cats) c.id: c};

            final chips = <Widget>[
              FilterChip(
                selected: selectedCategoryId == null,
                label: const Text('Toutes'),
                onSelected: (_) => setState(() => selectedCategoryId = null),
              ),
              ...cats.map(
                (c) => FilterChip(
                  selected: selectedCategoryId == c.id,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconFromKey(c.icon), size: 16, color: colorFromInt(c.color)),
                      const SizedBox(width: 6),
                      Text(c.name),
                    ],
                  ),
                  onSelected: (_) => setState(() => selectedCategoryId = c.id),
                ),
              )
            ];

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Row(
                    children: chips
                        .map((w) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: w,
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Expense>>(
                    stream: db.watchExpenses(),
                    builder: (context, snapshot) {
                      final all = snapshot.data ?? const <Expense>[];
                      final items = selectedCategoryId == null
                          ? all
                          : all.where((e) => e.categoryId == selectedCategoryId).toList();

                      if (items.isEmpty) {
                        return const Center(child: Text('Aucune dépense.'));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final e = items[i];
                          final cat = map[e.categoryId];
                          final c = cat == null ? null : colorFromInt(cat.color);

                          return Card(
                            child: ListTile(
                              leading: cat == null
                                  ? const Icon(Icons.category)
                                  : CircleAvatar(
                                      backgroundColor: c!.withValues(alpha: 0.15),
                                      child: Icon(iconFromKey(cat.icon), color: c),
                                    ),
                              title: Text(e.note),
                              subtitle: Text('${cat?.name ?? 'Catégorie'} • ${_fmtDate(e.spentAt)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${e.amount.toStringAsFixed(0)} DA',
                                      style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => db.deleteExpense(e.id),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
}

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
