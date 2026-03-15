import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import 'add_shopping_dialog.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return Stack(
      children: [
        StreamBuilder<List<Category>>(
          stream: db.watchCategories(),
          builder: (context, catSnap) {
            final cats = catSnap.data ?? const <Category>[];
            final catMap = {for (final c in cats) c.id: c};

            return StreamBuilder<List<ShoppingItem>>(
              stream: db.watchShopping(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <ShoppingItem>[];
                if (items.isEmpty) {
                  return const Center(child: Text('Liste vide. Ajoute un article.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final cat = catMap[it.categoryId];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: it.done,
                          onChanged: (v) => db.toggleShoppingDone(it.id, v ?? false),
                        ),
                        title: Text(
                          it.name,
                          style: TextStyle(
                            decoration: it.done ? TextDecoration.lineThrough : null,
                            color: it.done ? Colors.white60 : null,
                          ),
                        ),
                        subtitle: Text(cat?.name ?? 'Catégorie'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => db.deleteShoppingItem(it.id),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => showDialog(context: context, builder: (_) => const AddShoppingDialog()),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        )
      ],
    );
  }
}
