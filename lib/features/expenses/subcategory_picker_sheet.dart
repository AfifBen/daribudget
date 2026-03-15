import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';

class SubcategoryPickerSheet extends StatefulWidget {
  final int? initialSubcategoryId;

  const SubcategoryPickerSheet({super.key, this.initialSubcategoryId});

  @override
  State<SubcategoryPickerSheet> createState() => _SubcategoryPickerSheetState();
}

class _SubcategoryPickerSheetState extends State<SubcategoryPickerSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text('Choisir une sous‑catégorie', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Rechercher',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Category>>(
              future: db.listCategories(),
              builder: (context, catSnap) {
                final cats = catSnap.data ?? const <Category>[];
                final catMap = {for (final c in cats) c.id: c};

                return FutureBuilder<List<Subcategory>>(
                  future: db.select(db.subcategories).get(),
                  builder: (context, subSnap) {
                    final subs = subSnap.data ?? const <Subcategory>[];

                    final q = _searchCtrl.text.trim().toLowerCase();
                    final filtered = q.isEmpty
                        ? subs
                        : subs.where((s) {
                            final cat = catMap[s.categoryId];
                            final hay = '${cat?.name ?? ''} ${s.name}'.toLowerCase();
                            return hay.contains(q);
                          }).toList();

                    if (filtered.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 22),
                        child: Text('Aucun résultat.', style: TextStyle(color: Colors.white70)),
                      );
                    }

                    return Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
                        itemBuilder: (context, i) {
                          final s = filtered[i];
                          final cat = catMap[s.categoryId];
                          final selected = s.id == widget.initialSubcategoryId;

                          return ListTile(
                            leading: const Icon(Icons.category_outlined),
                            title: Text('${cat?.name ?? 'Catégorie'} / ${s.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: selected ? const Icon(Icons.check) : null,
                            onTap: () => Navigator.pop<int>(context, s.id),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
