import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  int? _categoryId;
  int? _subcategoryId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return AlertDialog(
      title: const Text('Ajouter une dépense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (DA)'),
              validator: (v) {
                final x = double.tryParse((v ?? '').trim());
                if (x == null || x <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Note'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Category>>(
              future: db.listCategories(),
              builder: (context, snapshot) {
                final cats = snapshot.data ?? const <Category>[];
                if (cats.isEmpty) return const Text('Aucune catégorie.');
                _categoryId ??= cats.first.id;

                return DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  items: [
                    for (final c in cats) DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _categoryId = v;
                      _subcategoryId = null; // reset
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                );
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Subcategory>>(
              future: _categoryId == null ? Future.value(const <Subcategory>[]) : db.listSubcategories(_categoryId!),
              builder: (context, snapshot) {
                final subs = snapshot.data ?? const <Subcategory>[];
                if (_categoryId == null) return const SizedBox.shrink();
                if (subs.isEmpty) return const Text('Aucune sous‑catégorie.');
                _subcategoryId ??= subs.first.id;

                return DropdownButtonFormField<int>(
                  initialValue: _subcategoryId,
                  items: [
                    for (final s in subs) DropdownMenuItem(value: s.id, child: Text(s.name)),
                  ],
                  onChanged: (v) => setState(() => _subcategoryId = v),
                  decoration: const InputDecoration(labelText: 'Sous‑catégorie'),
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
            if (_subcategoryId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisis une sous‑catégorie')));
              return;
            }
            await db.addExpense(
              amount: double.parse(_amountCtrl.text.trim()),
              note: _noteCtrl.text.trim(),
              subcategoryId: _subcategoryId!,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
