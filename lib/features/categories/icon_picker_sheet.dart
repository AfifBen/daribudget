import 'package:flutter/material.dart';

Future<String?> showIconPicker(BuildContext context, {String? initial}) {
  const icons = <String, IconData>{
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'receipt_long': Icons.receipt_long,
    'medical_services': Icons.medical_services,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'shopping_cart': Icons.shopping_cart,
    'home': Icons.home,
    'savings': Icons.savings,
    'category': Icons.category,
    'pets': Icons.pets,
    'flight': Icons.flight,
    'phone': Icons.phone,
    'local_cafe': Icons.local_cafe,
    'fastfood': Icons.fastfood,
    'local_grocery_store': Icons.local_grocery_store,
    'fitness_center': Icons.fitness_center,
    'child_care': Icons.child_care,
  };

  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choisir une icône', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 12),
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    for (final e in icons.entries)
                      InkWell(
                        onTap: () => Navigator.pop(context, e.key),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: e.key == initial ? const Color(0xFFD8B45C) : Colors.white12),
                            color: Colors.white10,
                          ),
                          child: Icon(e.value, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
