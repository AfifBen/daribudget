import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';

class AddBudgetDialog extends StatefulWidget {
  final String month;
  const AddBudgetDialog({super.key, required this.month});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  int? _categoryId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return AlertDialog(
      title: Text('Créer un budget (${widget.month})'),
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
            FutureBuilder<List<Category>>(
              future: db.listCategories(),
              builder: (context, snapshot) {
                final cats = snapshot.data ?? const <Category>[];
                if (cats.isEmpty) return const Text('Aucune catégorie.');
                _categoryId ??= cats.first.id;
                return DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  items: [for (final c in cats) DropdownMenuItem(value: c.id, child: Text(c.name))],
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
            await db.addBudget(
              amount: double.parse(_amountCtrl.text.trim()),
              month: widget.month,
              categoryId: _categoryId!,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Ajouter'),
        )
      ],
    );
  }
}
