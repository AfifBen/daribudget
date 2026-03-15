import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const MaterialPage(child: DashboardScreen()),
        routes: [
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) => const MaterialPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
}
