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

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              future: context.read<AppDb>().listCategories('expense'),
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
            await db.addExpense(
              amount: double.parse(_amountCtrl.text.trim()),
              note: _noteCtrl.text.trim(),
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
