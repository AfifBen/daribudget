import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expenses_screen.dart';
import '../budgets/budgets_screen.dart';
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solde du mois', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text('0 DA', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Ajouter dépense')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_chart), label: const Text('Créer budget')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.shopping_cart), label: const Text('Ajouter course')),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Langues: FR / AR / EN'),
            subtitle: const Text('RTL activé automatiquement en arabe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenSettings,
          ),
        ),
      ],
    );
  }
}
