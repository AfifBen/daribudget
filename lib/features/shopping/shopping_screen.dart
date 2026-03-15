import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../categories/category_ui.dart';
import 'add_shopping_dialog.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    return _ShoppingWithFilter(db: db);
  }
}

class _ShoppingWithFilter extends StatefulWidget {
  final AppDb db;
  const _ShoppingWithFilter({required this.db});

  @override
  State<_ShoppingWithFilter> createState() => _ShoppingWithFilterState();
}

class _ShoppingWithFilterState extends State<_ShoppingWithFilter> {
  int? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final db = widget.db;

    return Stack(
      children: [
        StreamBuilder<List<Category>>(
          stream: db.watchCategories('shopping'),
          builder: (context, catSnap) {
            final cats = catSnap.data ?? const <Category>[];
            final map = {for (final c in cats) c.id: c};

            final chips = <Widget>[
              FilterChip(
                selected: selectedCategoryId == null,
                label: const Text('Toutes'),
                onSelected: (_) => setState(() => selectedCategoryId = null),
              ),
              ...cats.map(
                (c) => FilterChip(
                  selected: selectedCategoryId == c.id,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconFromKey(c.icon), size: 16, color: colorFromInt(c.color)),
                      const SizedBox(width: 6),
                      Text(c.name),
                    ],
                  ),
                  onSelected: (_) => setState(() => selectedCategoryId = c.id),
                ),
              )
            ];

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Row(
                    children: chips
                        .map((w) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: w,
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<ShoppingItem>>(
                    stream: db.watchShopping(),
                    builder: (context, snapshot) {
                      final all = snapshot.data ?? const <ShoppingItem>[];
                      final items = selectedCategoryId == null
                          ? all
                          : all.where((it) => it.categoryId == selectedCategoryId).toList();

                      if (items.isEmpty) {
                        return const Center(child: Text('Liste vide.'));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final it = items[i];
                          final cat = map[it.categoryId];
                          final c = cat == null ? null : colorFromInt(cat.color);

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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (cat != null)
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: c!.withValues(alpha: 0.15),
                                      child: Icon(iconFromKey(cat.icon), size: 16, color: c),
                                    ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => db.deleteShoppingItem(it.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
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
