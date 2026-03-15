import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import 'add_expense_dialog.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return Stack(
      children: [
        StreamBuilder<List<Expense>>(
          stream: db.watchExpenses(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <Expense>[];
            if (items.isEmpty) {
              return const Center(child: Text('Aucune dépense. Ajoute la première.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final e = items[i];
                return Card(
                  child: ListTile(
                    title: Text(e.note),
                    subtitle: Text('${e.category} • ${_fmtDate(e.spentAt)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${e.amount.toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.w700)),
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
