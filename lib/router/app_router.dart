import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/categories/category_detail_screen.dart';
import '../features/categories/category_manager_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';
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
          GoRoute(
            path: 'history',
            pageBuilder: (context, state) => const MaterialPage(child: HistoryScreen()),
          ),
          GoRoute(
            path: 'categories',
            pageBuilder: (context, state) => const MaterialPage(child: CategoryManagerScreen()),
          ),
          GoRoute(
            path: 'category/:id/:month',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final month = state.pathParameters['month']!;
              return MaterialPage(child: CategoryDetailScreen(categoryId: id, monthKey: month));
            },
          ),
        ],
      ),
    ],
  );
}
