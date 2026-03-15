import 'package:flutter/material.dart';

Future<int?> showColorPicker(BuildContext context, {int? initial}) {
  const colors = <int>[
    0xFFD8B45C,
    0xFF4FC3F7,
    0xFFFFB74D,
    0xFFE57373,
    0xFFBA68C8,
    0xFF81C784,
    0xFF90A4AE,
    0xFFFF8A65,
    0xFFAED581,
    0xFF64B5F6,
  ];

  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in colors)
                InkWell(
                  onTap: () => Navigator.pop(context, c),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(c),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: c == initial ? Colors.white : Colors.transparent, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
