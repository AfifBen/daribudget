import 'package:flutter/material.dart';

import '../../db/app_db.dart';

IconData iconFromKey(String key) {
  switch (key) {
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_car':
      return Icons.directions_car;
    case 'receipt_long':
      return Icons.receipt_long;
    case 'medical_services':
      return Icons.medical_services;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'school':
      return Icons.school;
    case 'pie_chart':
      return Icons.pie_chart;
    case 'savings':
      return Icons.savings;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'home':
      return Icons.home;
    default:
      return Icons.category;
  }
}

Color colorFromInt(int argb) => Color(argb);

class CategoryBadge extends StatelessWidget {
  final Category category;
  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final c = colorFromInt(category.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.35)),
        color: c.withValues(alpha: 0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFromKey(category.icon), size: 16, color: c),
          const SizedBox(width: 8),
          Text(category.name, style: TextStyle(fontWeight: FontWeight.w700, color: c)),
        ],
      ),
    );
  }
}
