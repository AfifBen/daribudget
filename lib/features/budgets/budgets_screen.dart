import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../categories/category_ui.dart';
import 'add_budget_dialog.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  String get monthKey {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    return '${now.year}-$m';
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    final month = monthKey;
    return _BudgetsWithFilter(db: db, month: month);
  }
}

class _BudgetsWithFilter extends StatefulWidget {
  final AppDb db;
  final String month;
  const _BudgetsWithFilter({required this.db, required this.month});

  @override
  State<_BudgetsWithFilter> createState() => _BudgetsWithFilterState();
}

class _BudgetsWithFilterState extends State<_BudgetsWithFilter> {
  int? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final db = widget.db;

    return Stack(
      children: [
        StreamBuilder<List<Category>>(
          stream: db.watchCategories('budget'),
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
                  child: StreamBuilder<List<Budget>>(
                    stream: db.watchBudgets(widget.month),
                    builder: (context, snapshot) {
                      final all = snapshot.data ?? const <Budget>[];
                      final items = selectedCategoryId == null
                          ? all
                          : all.where((b) => b.categoryId == selectedCategoryId).toList();

                      if (items.isEmpty) {
                        return Center(child: Text('Aucun budget pour ${widget.month}.'));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final b = items[i];
                          final cat = map[b.categoryId];
                          final c = cat == null ? null : colorFromInt(cat.color);

                          return Card(
                            child: ListTile(
                              leading: cat == null
                                  ? const Icon(Icons.category)
                                  : CircleAvatar(
                                      backgroundColor: c!.withValues(alpha: 0.15),
                                      child: Icon(iconFromKey(cat.icon), color: c),
                                    ),
                              title: Text(cat?.name ?? 'Budget'),
                              subtitle: Text('Mois: ${b.month}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${b.amount.toStringAsFixed(0)} DA',
                                      style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => db.deleteBudget(b.id),
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
            onPressed: () => showDialog(context: context, builder: (_) => AddBudgetDialog(month: widget.month)),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        )
      ],
    );
  }
}
