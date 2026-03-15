import 'package:flutter/material.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Courses'),
            subtitle: Text('CRUD SQLite à implémenter (prochaine étape)'),
          ),
        ),
      ],
    );
  }
}
