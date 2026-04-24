import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../categories/category_ui.dart';
import 'subcategory_picker_sheet.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  static const _quickAmounts = <int>[100, 200, 500, 1000, 2000, 5000];

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  int? _subcategoryId;
  String _subcategoryLabel = 'Choisir…';
  String _subcategoryIcon = 'category';
  int _subcategoryColor = 0xFF9E9E9E;

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
      _subcategoryIcon = sub.icon;
      _subcategoryColor = sub.color;
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
                decoration: const InputDecoration(
                  labelText: 'Montant (DA)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) {
                  final x = double.tryParse((v ?? '').trim());
                  if (x == null || x <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final amount in _quickAmounts)
                      ActionChip(
                        label: Text('$amount DA'),
                        onPressed: () {
                          setState(() => _amountCtrl.text = '$amount');
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickSubcategory,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Sous‑catégorie (obligatoire)',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconFromKey(_subcategoryIcon),
                        size: 18,
                        color: Color(_subcategoryColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_subcategoryLabel, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optionnel)',
                  prefixIcon: Icon(Icons.edit_note),
                ),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text('Enregistrer'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
