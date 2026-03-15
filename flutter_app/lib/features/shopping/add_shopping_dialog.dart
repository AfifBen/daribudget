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
  final _catCtrl = TextEditingController(text: 'Général');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catCtrl.dispose();
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
            await db.addShoppingItem(
              name: _nameCtrl.text.trim(),
              category: _catCtrl.text.trim().isEmpty ? 'Général' : _catCtrl.text.trim(),
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
