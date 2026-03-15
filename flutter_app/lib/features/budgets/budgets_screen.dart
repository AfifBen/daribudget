import 'package:flutter/material.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.pie_chart),
            title: Text('Budgets'),
            subtitle: Text('CRUD SQLite à implémenter (prochaine étape)'),
          ),
        ),
      ],
    );
  }
}
