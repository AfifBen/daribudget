import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';

Future<void> showWeekStartPicker(BuildContext context) {
  final appState = context.read<AppState>();
  final current = appState.weekStart;

  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Début de semaine', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('Impacte le graphique hebdomadaire'),
            ),
            ListTile(
              leading: Icon(current == WeekStart.sunday ? Icons.radio_button_checked : Icons.radio_button_off),
              title: const Text('Dimanche (défaut)'),
              onTap: () {
                appState.setWeekStart(WeekStart.sunday);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(current == WeekStart.monday ? Icons.radio_button_checked : Icons.radio_button_off),
              title: const Text('Lundi'),
              onTap: () {
                appState.setWeekStart(WeekStart.monday);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
