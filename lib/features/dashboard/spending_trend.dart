import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../charts/bar_chart.dart';

enum TrendRange { day, week, month }

class SpendingTrend extends StatefulWidget {
  final String month;
  const SpendingTrend({super.key, required this.month});

  @override
  State<SpendingTrend> createState() => _SpendingTrendState();
}

class _SpendingTrendState extends State<SpendingTrend> {
  TrendRange range = TrendRange.week;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dépenses', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<TrendRange>(
                  segments: const [
                    ButtonSegment(value: TrendRange.day, label: Text('Jour')),
                    ButtonSegment(value: TrendRange.week, label: Text('Semaine')),
                    ButtonSegment(value: TrendRange.month, label: Text('Mois')),
                  ],
                  selected: {range},
                  onSelectionChanged: (s) => setState(() => range = s.first),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<BarDatum>>(
              future: _load(db),
              builder: (context, snap) {
                final data = snap.data ?? const <BarDatum>[];
                if (data.isEmpty) {
                  return const Text('Ajoute des dépenses pour voir la tendance.', style: TextStyle(color: Colors.white70));
                }
                return SimpleBarChart(data: data, height: 140);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<BarDatum>> _load(AppDb db) async {
    final m = widget.month;
    if (range == TrendRange.day) {
      // show last 7 days of current month
      final list = await db.expensesByDay(m);
      final last = list.length <= 7 ? list : list.sublist(list.length - 7);
      return [
        for (final t in last)
          BarDatum(label: t.key.substring(8, 10), value: t.total),
      ];
    }

    if (range == TrendRange.week) {
      final list = await db.expensesByWeekOfMonth(m);
      return [for (final t in list) BarDatum(label: t.key, value: t.total)];
    }

    // month: use weeks too (simple)
    final list = await db.expensesByWeekOfMonth(m);
    return [for (final t in list) BarDatum(label: t.key, value: t.total)];
  }
}
