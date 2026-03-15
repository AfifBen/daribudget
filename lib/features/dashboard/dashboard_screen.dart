import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../budgets/budgets_screen.dart';
import '../expenses/expenses_screen.dart';
import '../shopping/shopping_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _DashboardHome(),
      const ExpensesScreen(),
      const BudgetsScreen(),
      const ShoppingScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('DariBudget'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(child: pages[index]),
      floatingActionButton: index == 0
          ? FloatingActionButton(
              onPressed: () => _showQuickActions(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Dépenses'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Courses'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    final month = _currentMonthKey();

    return StreamBuilder<List<Category>>(
      stream: db.watchCategories('expense'),
      builder: (context, catSnap) {
        final cats = catSnap.data ?? const <Category>[];
        final cache = {for (final c in cats) c.id: c.name};

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TopBar(month: month),
            const SizedBox(height: 12),

            // Hero metrics card
            StreamBuilder<List<Expense>>(
              stream: db.watchExpensesForMonth(month),
              builder: (context, expSnap) {
                final expenses = expSnap.data ?? const <Expense>[];
                final totalExpenses = expenses.fold<double>(0, (s, e) => s + e.amount);

                return StreamBuilder<List<Budget>>(
                  stream: db.watchBudgets(month),
                  builder: (context, budSnap) {
                    final budgets = budSnap.data ?? const <Budget>[];
                    final totalBudgets = budgets.fold<double>(0, (s, b) => s + b.amount);
                    final remaining = totalBudgets - totalExpenses;

                    return _HeroCard(
                      month: month,
                      totalExpenses: totalExpenses,
                      totalBudgets: totalBudgets,
                      remaining: remaining,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            // Recent expenses preview
            StreamBuilder<List<Expense>>(
              stream: db.watchExpensesForMonth(month),
              builder: (context, snap) {
                final items = snap.data ?? const <Expense>[];
                final top = items.take(4).toList();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Dernières dépenses', style: TextStyle(fontWeight: FontWeight.w800)),
                            Text(month, style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (top.isEmpty)
                          const Text('Aucune dépense ce mois‑ci.', style: TextStyle(color: Colors.white70))
                        else
                          ...top.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.note, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_catName(e.categoryId, cache)} • ${_fmtDate(e.spentAt)}',
                                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('${e.amount.toStringAsFixed(0)} DA', style: const TextStyle(fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final String month;
  const _TopBar({required this.month});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Vue d\'ensemble',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Text(month, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String month;
  final double totalExpenses;
  final double totalBudgets;
  final double remaining;

  const _HeroCard({
    required this.month,
    required this.totalExpenses,
    required this.totalBudgets,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (totalBudgets <= 0) ? 0.0 : (totalExpenses / totalBudgets).clamp(0.0, 1.0).toDouble();
    final percent = (ratio * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solde du mois', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
            const SizedBox(height: 10),
            Text(
              '${remaining.toStringAsFixed(0)} DA',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(month, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _StatPill(label: 'Dépenses', value: '${totalExpenses.toStringAsFixed(0)} DA', icon: Icons.payments),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatPill(label: 'Budgets', value: '${totalBudgets.toStringAsFixed(0)} DA', icon: Icons.pie_chart),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (totalBudgets <= 0)
              const Text('Ajoute un budget pour voir la progression.', style: TextStyle(color: Colors.white70))
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Utilisé $percent%', style: const TextStyle(color: Colors.white70)),
                  Text('Reste ${(totalBudgets - totalExpenses).toStringAsFixed(0)} DA', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: Colors.white10,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatPill({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showQuickActions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(title: Text('Actions rapides', style: TextStyle(fontWeight: FontWeight.w900))),
            ListTile(leading: Icon(Icons.payments), title: Text('Ajouter une dépense'), subtitle: Text('Saisie rapide')), 
            ListTile(leading: Icon(Icons.pie_chart), title: Text('Créer un budget'), subtitle: Text('Par catégorie / mois')),
            ListTile(leading: Icon(Icons.shopping_cart), title: Text('Ajouter une course'), subtitle: Text('Liste de courses')),
            SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

String _catName(int categoryId, Map<int, String> cache) => cache[categoryId] ?? 'Catégorie';

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
