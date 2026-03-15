import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';

class AddShoppingDialog extends StatefulWidget {
  const AddShoppingDialog({super.key});

  @override
  State<AddShoppingDialog> createState() => _AddShoppingDialogState();
}

class _AddShoppingDialogState extends State<AddShoppingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  int? _categoryId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une course'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Article'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Category>>(
              future: context.read<AppDb>().listCategories('shopping'),
              builder: (context, snapshot) {
                final cats = snapshot.data ?? const <Category>[];
                if (cats.isEmpty) {
                  return const Text('Aucune catégorie.');
                }
                _categoryId ??= cats.first.id;
                return DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  items: [
                    for (final c in cats)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () async {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            final db = context.read<AppDb>();
            await db.addShoppingItem(
              name: _nameCtrl.text.trim(),
              categoryId: _categoryId!,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
