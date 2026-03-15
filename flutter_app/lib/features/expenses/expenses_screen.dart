import 'package:flutter/material.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.payments),
            title: Text('Dépenses'),
            subtitle: Text('CRUD SQLite à implémenter (prochaine étape)'),
          ),
        ),
      ],
    );
  }
}
