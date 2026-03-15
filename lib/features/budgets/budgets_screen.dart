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

    return Stack(
      children: [
        StreamBuilder<List<Category>>(
          stream: db.watchCategories('budget'),
          builder: (context, catSnap) {
            final cats = catSnap.data ?? const <Category>[];
            final map = {for (final c in cats) c.id: c};

            return StreamBuilder<List<Budget>>(
              stream: db.watchBudgets(month),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <Budget>[];
                if (items.isEmpty) {
                  return Center(child: Text('Aucun budget pour $month.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final b = items[i];
                    final cat = map[b.categoryId];
                    return Card(
                      child: ListTile(
                        leading: cat == null
                            ? const Icon(Icons.category)
                            : CircleAvatar(
                                backgroundColor: colorFromInt(cat.color).withValues(alpha: 0.15),
                                child: Icon(iconFromKey(cat.icon), color: colorFromInt(cat.color)),
                              ),
                        title: Text(cat?.name ?? 'Budget'),
                        subtitle: Text('Mois: ${b.month}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${b.amount.toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.w800)),
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
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => showDialog(context: context, builder: (_) => AddBudgetDialog(month: month)),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        )
      ],
    );
  }
}
