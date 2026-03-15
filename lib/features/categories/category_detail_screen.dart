import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../charts/pie_chart.dart';

class CategoryDetailScreen extends StatelessWidget {
  final int categoryId;
  final String monthKey;

  const CategoryDetailScreen({super.key, required this.categoryId, required this.monthKey});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return Scaffold(
      appBar: AppBar(title: const Text('Détails catégorie')),
      body: FutureBuilder<List<SubcategoryTotal>>(
        future: db.expensesBySubcategoryForMonth(monthKey, categoryId: categoryId),
        builder: (context, snap) {
          final rows = (snap.data ?? const <SubcategoryTotal>[]).where((r) => r.total > 0).toList();
          final total = rows.fold<double>(0, (s, r) => s + r.total);

          if (rows.isEmpty) {
            return const Center(child: Text('Aucune dépense dans cette catégorie.'));
          }

          final top = rows.take(7).toList();
          final rest = rows.skip(7).fold<double>(0, (s, r) => s + r.total);
          final slices = <PieSlice>[
            for (final r in top) PieSlice(value: r.total, color: Color(r.color), label: r.name),
            if (rest > 0) const PieSlice(value: 0, color: Colors.white24, label: 'Autres'),
          ];
          if (rest > 0) slices[slices.length - 1] = PieSlice(value: rest, color: Colors.white24, label: 'Autres');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Répartition par sous‑catégorie', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SimplePieChart(slices: slices, size: 150),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              children: [
                                for (final s in slices)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(99))),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        const SizedBox(width: 8),
                                        Text('${((s.value / total) * 100).round()}%', style: const TextStyle(color: Colors.white70)),
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
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    const ListTile(title: Text('Top sous‑catégories', style: TextStyle(fontWeight: FontWeight.w900))),
                    for (final r in rows.take(10))
                      ListTile(
                        title: Text(r.name),
                        trailing: Text('${r.total.toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
