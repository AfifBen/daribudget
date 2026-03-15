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
  final _catCtrl = TextEditingController(text: 'Général');

  @override
  void dispose() {
    _amountCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            TextFormField(
              controller: _catCtrl,
              decoration: const InputDecoration(labelText: 'Catégorie'),
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
            await db.addBudget(
              amount: double.parse(_amountCtrl.text.trim()),
              month: widget.month,
              category: _catCtrl.text.trim().isEmpty ? 'Général' : _catCtrl.text.trim(),
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Ajouter'),
        )
      ],
    );
  }
}
