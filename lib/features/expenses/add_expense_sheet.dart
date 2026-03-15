import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import 'subcategory_picker_sheet.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  int? _subcategoryId;
  String _subcategoryLabel = 'Choisir…';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickSubcategory() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SubcategoryPickerSheet(initialSubcategoryId: _subcategoryId),
    );

    if (!mounted || picked == null) return;

    final db = context.read<AppDb>();
    final sub = await (db.select(db.subcategories)..where((t) => t.id.equals(picked))).getSingleOrNull();
    if (sub == null) return;
    final cat = await (db.select(db.categories)..where((t) => t.id.equals(sub.categoryId))).getSingleOrNull();

    setState(() {
      _subcategoryId = picked;
      _subcategoryLabel = '${cat?.name ?? 'Catégorie'} / ${sub.name}';
    });
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text('Ajouter une dépense', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickSubcategory,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Sous‑catégorie (obligatoire)',
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(_subcategoryLabel, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optionnel)'),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    if (_subcategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisis une sous‑catégorie')));
                      return;
                    }

                    await db.addExpense(
                      amount: double.parse(_amountCtrl.text.trim()),
                      note: _noteCtrl.text.trim().isEmpty ? 'Dépense' : _noteCtrl.text.trim(),
                      subcategoryId: _subcategoryId!,
                    );

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
