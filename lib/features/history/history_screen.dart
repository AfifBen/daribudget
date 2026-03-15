import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    final month = _currentMonthKey();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historique'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dépenses'),
              Tab(text: 'Courses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<List<Expense>>(
              stream: db.watchExpensesForMonth(month),
              builder: (context, snap) {
                final items = snap.data ?? const <Expense>[];
                if (items.isEmpty) return const Center(child: Text('Aucune dépense.'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final e = items[i];
                    return Card(
                      child: ListTile(
                        title: Text(e.note, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(_fmtDate(e.spentAt), style: const TextStyle(color: Colors.white60)),
                        trailing: Text('${e.amount.toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<List<ShoppingItem>>(
              stream: db.watchShopping(),
              builder: (context, snap) {
                final items = snap.data ?? const <ShoppingItem>[];
                if (items.isEmpty) return const Center(child: Text('Liste vide.'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: it.done,
                          onChanged: (v) => db.toggleShoppingDone(it.id, v ?? false),
                        ),
                        title: Text(it.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => db.deleteShoppingItem(it.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
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
