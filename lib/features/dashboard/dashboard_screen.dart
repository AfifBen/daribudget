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
      _DashboardHome(onOpenSettings: () => context.go('/settings')),
      const ExpensesScreen(),
      const BudgetsScreen(),
      const ShoppingScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('DariBudget'),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(child: pages[index]),
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
  final VoidCallback onOpenSettings;
  const _DashboardHome({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    final month = currentMonthKey();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mois', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(month, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: Card(
                child: ListTile(
                  title: const Text('Langue'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenSettings,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),

        // Metrics
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

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Solde du mois', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('${remaining.toStringAsFixed(0)} DA',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricTile(
                                label: 'Dépenses',
                                value: '${totalExpenses.toStringAsFixed(0)} DA',
                                icon: Icons.payments,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricTile(
                                label: 'Budgets',
                                value: '${totalBudgets.toStringAsFixed(0)} DA',
                                icon: Icons.pie_chart,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _BudgetProgress(totalBudgets: totalBudgets, totalExpenses: totalExpenses),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 12),

        // Quick actions placeholder (real actions are on each screen)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _QuickChip(icon: Icons.add, label: 'Ajouter dépense'),
                _QuickChip(icon: Icons.add_chart, label: 'Créer budget'),
                _QuickChip(icon: Icons.shopping_cart, label: 'Ajouter course'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({required this.label, required this.value, required this.icon});

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
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final double totalBudgets;
  final double totalExpenses;
  const _BudgetProgress({required this.totalBudgets, required this.totalExpenses});

  @override
  Widget build(BuildContext context) {
    if (totalBudgets <= 0) {
      return const Text('Ajoute un budget pour voir la progression.', style: TextStyle(color: Colors.white70));
    }
    final ratio = (totalExpenses / totalBudgets).clamp(0, 1);
    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
