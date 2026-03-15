import 'package:flutter/material.dart';

class BarDatum {
  final String label;
  final double value;

  const BarDatum({required this.label, required this.value});
}

class SimpleBarChart extends StatelessWidget {
  final List<BarDatum> data;
  final double height;

  const SimpleBarChart({super.key, required this.data, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final maxV = data.fold<double>(0, (m, d) => d.value > m ? d.value : m);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: maxV <= 0 ? 2 : (d.value / maxV) * (height - 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8B45C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(d.label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
