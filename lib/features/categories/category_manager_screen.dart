import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createCategory(context, db),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Category>>(
        stream: db.watchCategories(),
        builder: (context, catSnap) {
          final cats = catSnap.data ?? const <Category>[];
          if (cats.isEmpty) return const Center(child: Text('Aucune catégorie.'));

          return StreamBuilder<List<Subcategory>>(
            stream: db.select(db.subcategories).watch(),
            builder: (context, subSnap) {
              final subs = subSnap.data ?? const <Subcategory>[];
              final byCat = <int, List<Subcategory>>{};
              for (final s in subs) {
                (byCat[s.categoryId] ??= []).add(s);
              }
              for (final list in byCat.values) {
                list.sort((a, b) => a.name.compareTo(b.name));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final c in cats)
                    Card(
                      child: ExpansionTile(
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('Sous‑catégories: ${(byCat[c.id]?.length ?? 0)}', style: const TextStyle(color: Colors.white70)),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'rename') _renameCategory(context, db, c);
                            if (v == 'delete') _deleteCategory(context, db, c);
                            if (v == 'addSub') _createSubcategory(context, db, c.id);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'addSub', child: Text('Ajouter sous‑catégorie')),
                            PopupMenuItem(value: 'rename', child: Text('Renommer')),
                            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                          ],
                        ),
                        children: [
                          if ((byCat[c.id] ?? const <Subcategory>[]).isEmpty)
                            const ListTile(title: Text('Aucune sous‑catégorie')),
                          for (final s in (byCat[c.id] ?? const <Subcategory>[]))
                            ListTile(
                              title: Text(s.name),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'rename') _renameSubcategory(context, db, s);
                                  if (v == 'delete') _deleteSubcategory(context, db, s);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'rename', child: Text('Renommer')),
                                  PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> _createCategory(BuildContext context, AppDb db) async {
  final name = await _promptText(context, title: 'Nouvelle catégorie', hint: 'Ex: Alimentation');
  if (name == null) return;
  await db.createCategory(name: name.trim(), icon: 'category', color: 0xFFD8B45C);
}

Future<void> _renameCategory(BuildContext context, AppDb db, Category c) async {
  final name = await _promptText(context, title: 'Renommer catégorie', initial: c.name);
  if (name == null) return;
  await db.updateCategory(c.id, name: name.trim());
}

Future<void> _deleteCategory(BuildContext context, AppDb db, Category c) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Supprimer ?'),
      content: Text('Supprimer la catégorie “${c.name}” ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
      ],
    ),
  );
  if (ok != true) return;

  final deleted = await db.deleteCategory(c.id);
  if (!context.mounted) return;
  if (!deleted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible: catégorie utilisée par des dépenses.')));
  }
}

Future<void> _createSubcategory(BuildContext context, AppDb db, int categoryId) async {
  final name = await _promptText(context, title: 'Nouvelle sous‑catégorie', hint: 'Ex: Fruits');
  if (name == null) return;
  await db.createSubcategory(categoryId: categoryId, name: name.trim(), icon: 'category', color: 0xFFD8B45C);
}

Future<void> _renameSubcategory(BuildContext context, AppDb db, Subcategory s) async {
  final name = await _promptText(context, title: 'Renommer sous‑catégorie', initial: s.name);
  if (name == null) return;
  await db.updateSubcategory(s.id, name: name.trim());
}

Future<void> _deleteSubcategory(BuildContext context, AppDb db, Subcategory s) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Supprimer ?'),
      content: Text('Supprimer la sous‑catégorie “${s.name}” ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
      ],
    ),
  );
  if (ok != true) return;

  final deleted = await db.deleteSubcategory(s.id);
  if (!context.mounted) return;
  if (!deleted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible: sous‑catégorie utilisée par des dépenses.')));
  }
}

Future<String?> _promptText(BuildContext context, {required String title, String? hint, String? initial}) {
  final ctrl = TextEditingController(text: initial ?? '');
  return showDialog<String?>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: hint ?? 'Nom'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('OK')),
      ],
    ),
  );
}
